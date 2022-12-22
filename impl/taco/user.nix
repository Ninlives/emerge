{ ... }: {
  users.users.kavita = {
    uid = 954;
    group = "kavita";
    isSystemUser = true;
  };
  users.groups.kavita.gid = 954;

  users.users.jellyfin = {
    uid = 953;
    group = "jellyfin";
    isSystemUser = true;
  };
  users.groups.jellyfin.gid = 953;
}
