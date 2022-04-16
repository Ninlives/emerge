from qutebrowser.api import cmdutils, message
from subprocess import call

config.load_autoconfig(True)

acl_proxy    = 'socks://@sPROXY_ADDRESS@:@sACL_PORT@'
global_proxy = 'socks://@sPROXY_ADDRESS@:@sLOCAL_PORT@'

c.content.javascript.can_access_clipboard = True;
c.content.proxy = acl_proxy
c.scrolling.smooth = True
c.auto_save.session = True
c.content.pdfjs = True
c.qt.highdpi = True

c.logging.level.console = "info"
c.logging.level.ram = "info"

config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('<Ctrl-p>', 'spawn --userscript @sVAULTWARDEN_SCRIPT@', mode='insert')

@cmdutils.register()
def toggle_proxy():
    if c.content.proxy == global_proxy:
        c.content.proxy = acl_proxy
        message.info(f"Switch to acl proxy: {acl_proxy}")
    elif c.content.proxy == acl_proxy:
        c.content.proxy = 'none'
        message.info(f"Switch proxy to none")
    else:
        c.content.proxy = global_proxy
        message.info(f"Switch to global proxy: {global_proxy}")

call(['@sKEYCTL@', 'new_session', 'qute'])
