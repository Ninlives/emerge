function tp(){
    local f=$HOME/.cache/location
    if [[ ! -e $f || "$(cat $f)" == "Matrix" ]];then
        echo Follow the white rabbit
        sudo $(realpath $(which speech)) @redirPort@
        echo Zion > $f
    else
        echo Knock knock Neo
        sudo $(realpath $(which speechless))
        echo Matrix > $f
    fi
}

function tps(){
    local f=$HOME/.cache/location
    if [[ ! -e $f ]];then
        echo Location: Matrix
    else
        echo Location: $(cat $f)
    fi
}

function vpns(){
    local f=$HOME/.cache/proxy
    if [[ ! -e $f ]];then
        echo Proxy: v2ray
    else
        echo Proxy: $(cat $f)
    fi
}

function vpnt(){
    local f=$HOME/.cache/proxy
    if [[ ! -e $f || "$(cat $f)" == "v2ray" ]];then
        systemctl stop v2ray-trojan.service
        systemctl start v2ray-fallback.service
        echo fallback > $f
    else
        systemctl stop v2ray-fallback.service
        systemctl start v2ray-trojan.service
        echo v2ray > $f
    fi
}
