#!/usr/bin/env python

import gi

gi.require_version("AccountsService", "1.0")
from gi.repository import AccountsService

def main():
    # FIXME: hardcoded sessions and users
    user_manager = AccountsService.UserManager.get_default()
    # TODO: figure out why this line is needed
    user_manager.list_users()

    mlatus = user_manager.get_user("mlatus")
    mlatus.set_x_session("gnome")
    mlatus.set_session("gnome")
    mlatus.set_session_type("wayland")

    deck = user_manager.get_user("deck")
    deck.set_session("gamescope-wayland")
    deck.set_session_type("wayland")

if __name__ == "__main__":
    main()
