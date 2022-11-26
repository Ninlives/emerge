const Main = imports.ui.main;
const St = imports.gi.St;
const GObject = imports.gi.GObject;
const Gio = imports.gi.Gio;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Me = imports.misc.extensionUtils.getCurrentExtension();

let indicator;

const Indicator = GObject.registerClass(
class Indicator extends PanelMenu.Button {

  _init () {

    super._init(0);

    this.icons = {
      "0": Gio.icon_new_for_string( Me.dir.get_path() + '/laptop.svg' ),
      "1": Gio.icon_new_for_string( Me.dir.get_path() + '/tablet.svg')
    }

    let gschema = Gio.SettingsSchemaSource.new_from_directory(
      Me.dir.get_child('schemas').get_path(),
      Gio.SettingsSchemaSource.get_default(),
      false
    );
    this.settings = new Gio.Settings({
      settings_schema: gschema.lookup('org.gnome.shell.extensions.indicator', true)
    });
    this._onModeChangedId = this.settings.connect('changed::mode', this._onModeChanged.bind(this));

    this.icon = new St.Icon({
      gicon : this.icons[this.settings.get_enum('mode')],
      style_class : 'system-status-icon',
    });
    this.add_child(this.icon);
  }

  _onModeChanged(settings, key) {
    this.icon.set_gicon(this.icons[this.settings.get_enum('mode')]);
  }
});


function init() {}

function enable() {
  indicator = new Indicator();
  Main.panel.addToStatusArea('indicator', indicator, 1);
}

function disable() {
  indicator.destroy();
}

