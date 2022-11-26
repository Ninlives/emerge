#!/usr/bin/env bash
rofi_menu(){
    rofi -dmenu -p 'Items' \
        -markup-rows \
        -i -no-custom -format i \
        -mesg "<b>Alt+u</b>: Copy username | <b>Alt+p</b>: Copy password" \
        -kb-custom-1 'Alt+u' \
        -kb-custom-2 'Alt+p' \
        -font 'Mono 27'
}

show_message(){
  local message="$1"

  rofi -e "$message" -font 'Mono 27'
}

exit_error() {
  show_message "$1"
  exit 127
}

exit_normal(){
  show_message "$1"
  exit 0
}

show_items(){
    items=$(bw list items --url "$QUTE_URL"|jq -r -c '[sort_by(.id)|.[]|select(has("login"))|{id: .id, name: .name}]')
    length=$(echo $items|jq 'length')

    if [[ $length -le 0 ]];then
        show_all_items
    else
        selection=$(echo $items|jq -r '.[]|.name'|cat - <(echo "<i>Select from all items</i>")|rofi_menu)
        code=$?
        if [[ $selection -ge $length ]];then
            show_all_items
        else
            if [[ $selection -lt 0 ]];then
                exit_normal "No item selected."
            fi
            id=$(echo $items|jq -r ".[$selection].id")
            action $id $code
        fi
    fi
}

show_all_items(){
    items=$(bw list items|jq -r -c '[sort_by(.id)|.[]|select(has("login"))|{id: .id, name: .name}]')
    length=$(echo $items|jq 'length')
    selection=$(echo $items|jq -r '.[]|.name'|rofi_menu)
    code=$?
    if [[ $selection -lt 0 || -z "$selection" ]];then
        exit_error "No item selected."
    fi
    id=$(echo $items|jq -r ".[$selection].id")
    action $id $code
}

action(){
    bw list items|jq -r '.[]|select(.id == "'"$1"'")|(.login.username,.login.password)'| {
        read -r username;
        read -r password;
        case "$2" in
            10) echo $username|xclip -in -selection clipboard
                ;;
            11) echo $password|xclip -in -selection clipboard
                ;;
            0)  fill_password $username $password
                ;;
            *)  exit_error "Unknown action."
        esac
    }
}

javascript_escape() {
    # print the first argument in an escaped way, such that it can safely
    # be used within javascripts double quotes
    # shellcheck disable=SC2001
    sed "s,[\\\\'\"],\\\\&,g" <<< "$1"
}

js() {
cat <<EOF
    function isVisible(elem) {
        var style = elem.ownerDocument.defaultView.getComputedStyle(elem, null);
        if (style.getPropertyValue("visibility") !== "visible" ||
            style.getPropertyValue("display") === "none" ||
            style.getPropertyValue("opacity") === "0") {
            return false;
        }
        return elem.offsetWidth > 0 && elem.offsetHeight > 0;
    };
    function hasPasswordField(form) {
        var inputs = form.getElementsByTagName("input");
        for (var j = 0; j < inputs.length; j++) {
            var input = inputs[j];
            if (input.type == "password") {
                return true;
            }
        }
        return false;
    };
    function loadData2Form (form) {
        var inputs = form.getElementsByTagName("input");
        for (var j = 0; j < inputs.length; j++) {
            var input = inputs[j];
            if (isVisible(input) && (input.type == "text" || input.type == "email")) {
                input.focus();
                input.value = "$(javascript_escape "$1")";
                input.dispatchEvent(new Event('change'));
                input.blur();
            }
            if (input.type == "password") {
                input.focus();
                input.value = "$(javascript_escape "$2")";
                input.dispatchEvent(new Event('change'));
                input.blur();
            }
        }
    };
    var forms = document.getElementsByTagName("form");
    for (i = 0; i < forms.length; i++) {
        if (hasPasswordField(forms[i])) {
            loadData2Form(forms[i]);
        }
    }
EOF
}

fill_password(){
    echo "jseval -q $(js "$1" "$2"|sed 's,//.*$,,'|tr '\n' ' ')" >> "$QUTE_FIFO"
}

ask_password(){
    mpw=$(rofi -dmenu -p "Master Password" -password -lines 0 -font 'Mono 27') || exit_error "Unlock Failed."
    echo $mpw | bw unlock --raw || exit_error "Unlock Failed."
}

set_session_key(){
    need_reset=0

    if ! key_id=$(keyctl request user bw:session @s 2> /dev/null);then
        need_reset=1
    fi

    export BW_SESSION=$(keyctl pipe "$key_id")
    if [[ $(bw status|jq -r '.["status"]') != "unlocked" ]];then
        need_reset=1
    fi
    
    if [[ "$need_reset" == "1" ]];then
        session_key=$(ask_password)
        [[ -z "$session_key" ]] && echo "Could not unlock vault." && exit 1
        key_id=$(echo "$session_key" | keyctl padd user bw:session @s)
        export BW_SESSION=$session_key
    fi
}

echo 'message-info "Checking authentication status..."' >> "$QUTE_FIFO"
if [[ $(bw status | jq -r '.["status"]') == "unauthenticated" ]];then
    echo 'message-info "Logging in..."' >> "$QUTE_FIFO"
    bw config server https://@sVAULTWARDEN_HOST@
    export BW_CLIENTID=$(cat '@sVAULTWARDEN_CLIENTID@')
    export BW_CLIENTSECRET=$(cat '@sVAULTWARDEN_CLIENTSECRET@')
    bw login --apikey || exit_error "Login Failed."
fi

set_session_key
show_items
