{
  age = {
    server = {
      pubkey =
        "ENC[AES256_GCM,data:OrzMCpUeZ4/tk42w/BztfBQFSb7UivwfH++bnb8nhdL31TfZgNwfLDIs2HtaqE7eiDR3kPHq7YB19CXxEQ0=,iv:/A8PBaof9U2/Dogvkm9daQMqHANFpCEpLb72HvS1u7U=,tag:hgSSMAwtIc4xgKuwSr49uA==,type:str]";
    };
  };
  email =
    "ENC[AES256_GCM,data:wuOX3j2+XXMs6uipKiXtdjvlSg==,iv:KCkir9k425slnigBc8m5kNx2Mp11+ag1/thDI/PdwAM=,tag:g+1SvbyYPRcHnpwjc5IVyg==,type:str]";
  host =
    "ENC[AES256_GCM,data:qSdmRFjENaueeHM=,iv:iKZh/tpKoC1LCEMXWN17/f9R29kD9pAeT+rY7cEAkIA=,tag:Jh/xkJA7f4TN/jVy+y5G0w==,type:str]";
  immich = {
    port =
      "ENC[AES256_GCM,data:E8eKQyQ=,iv:stt8D6DLrNb6hL3tMCMBAp8jzGOt8itH3GAYF3yzAd4=,tag:91l1+Y3UKUYmUpsat4LVEw==,type:float]";
    subdomain =
      "ENC[AES256_GCM,data:EA==,iv:ejFKbUpBiMsbvoap/G1NnL603wv/sHbrZPuAyQkyHQc=,tag:Nw9OKFeISGUx9a9I8Wgdyg==,type:str]";
  };
  jellyfin = {
    subdomain =
      "ENC[AES256_GCM,data:xw==,iv:Mh88yZycz3rl+o9RBVp7Dyyw+SVzPUlD6OwKd7UvEAA=,tag:4NHfjk6XWBncnIOwXdQcpw==,type:str]";
  };
  kavita = {
    subdomain =
      "ENC[AES256_GCM,data:3A==,iv:vlwc0cVvSyIosVBc9nHwlpdBurE0WMy5LQmIuLFDtdM=,tag:38N8/zmmbBxtAaBhYKa2LQ==,type:str]";
  };
  libreddit = {
    port =
      "ENC[AES256_GCM,data:bqhkjP8=,iv:GugrmWocKLjGJUtPzKOo37qKxwlAgPcMtL7weAsIbJ0=,tag:sAwUIDUwaRWekNUdnH/esA==,type:float]";
    subdomain =
      "ENC[AES256_GCM,data:yg==,iv:vbY2EgM02FW9KNZuQM9kfqOvG0A3g2LiP+t1JlWH5/4=,tag:K72c+BshHDQv+94MSuJu9Q==,type:str]";
  };
  mail-server = {
    domain =
      "ENC[AES256_GCM,data:T9WcZOiB/w5JDDE=,iv:TDUJEaIQm6HuCBX4QbWk2B5xjCqajf/dIEnVW6MdIw0=,tag:BrDoMnxlyWkj3cqTkACqTQ==,type:str]";
    host =
      "ENC[AES256_GCM,data:X/CHzlZpp+xcXQK5X90=,iv:aTD+tDVLjekq+AvZkhon9y0wpZbomhicnOy2rlNtPXo=,tag:YpysncRdGfdLXCRf6Pg4Pg==,type:str]";
  };
  nix = {
    store = {
      pubkey =
        "ENC[AES256_GCM,data:Qd0VEXq8eVlz4fF4413YfYwDmC0we49CPzZolZ/mb85x4il9iVWElTDbgIy+EXDPTw==,iv:d8KSMHd1ESjR+RtUqdOVK9QUgmoMFogofziy4I8L2eg=,tag:FucoV3+WgRDScu/OQ0XV1Q==,type:str]";
    };
  };
  ptr =
    "ENC[AES256_GCM,data:PtyVc+77Hv9vB3k=,iv:a2iX5ApenM3RpEQ76ZPkUEqlZMGQvfh6AsTzuSXjGUc=,tag:sApTdfiGV6vlkAyiR/NoNg==,type:str]";
  rathole = {
    port =
      "ENC[AES256_GCM,data:xt0ERXY=,iv:EDFK4nm93/g0LCEDxEUZGvheoP9PATXydRgGxD+hzDY=,tag:1/1VgIQxSN041AdhBYLYZQ==,type:float]";
  };
  sops = {
    age = [{
      enc = ''
        -----BEGIN AGE ENCRYPTED FILE-----
        YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBMZHZPUXZZNFc2VkFjSVhU
        cndiNy9JdUdrSnJ2ZEIweUliQjdVcmFlSWtFCkkrSXVZdWUzUTFuV0VFWHF2WW1G
        L3lLWlFrSlJKYVI1SWY1SUVkbEtlYmMKLS0tIDNJbTFhTG4vckFKZGpHcFhMNDI4
        Yzh3VjBHOHE1N0dqTUxWaFdUVE4rVG8KVUxvVFLqEjeEO7WV7DUpv1h9LJdkrWy2
        sPiinm/W5JPCiNaUnxP3SrlHLqGHLWF5MEptZ1ViDN787LYqNTg/BQ==
        -----END AGE ENCRYPTED FILE-----
      '';
      recipient =
        "age1z45qh5zan89fy9swamy40rrvsnragat4jsuerl8ufk7fq5kl43mstre7m3";
    }];
    azure_kv = null;
    gcp_kms = null;
    hc_vault = null;
    kms = null;
    lastmodified = "2022-12-22T17:13:04Z";
    mac =
      "ENC[AES256_GCM,data:cHBO9ihKVjqprJrdmaPZQLToj9QniNYoIELlZ5Dk9akoutetGvNeZoxguTB2J99SUlPe+2tXlhD0y7LIf6SH347oLT70rpYsWGaPm+KQrQ9QPEAnuwx2dCyM1zrPG9mwcMlEFXL05qLDwiNTh9L0JEVeNakgxcRHHJvWeKPh/8Q=,iv:EGyWG7xOllyKecehuKKXnRGnAwpoYmihjX6BRtWDY9Y=,tag:lnE2nEeVQHgptrD0Ginfdg==,type:str]";
    pgp = null;
    unencrypted_suffix = "_unencrypted";
    version = "3.7.3";
  };
  ssh = {
    auth =
      "ENC[AES256_GCM,data:JAZYssm7z08vyMvcIyVZhGcS77+TUHdu8Pvxlwo7IwJ3HKwhPLH8GAV7kPjE8c+Y84zntgsPf3dGtAtSf2eu3agAAx0nIHR9PEqwfFzYU8BPqrqKBGi0q4RgWWL8xSCVUdR0cg==,iv:ch1ME+C2m20+oH3t5VIMNoJRaVnBZ5j2XaexLBRGupk=,tag:Lmpkd9WYj+hV6k3OQUL1Ew==,type:str]";
    port =
      "ENC[AES256_GCM,data:UKOaZls=,iv:z7GA1Sv71pmZ3qj4dSlnoZZzSBQP5vcrPPF/mxFh7pM=,tag:azrAFysFb7JlCgtzImcsmw==,type:float]";
  };
  trojan = {
    port =
      "ENC[AES256_GCM,data:lWHUqw==,iv:MAKthpuF8BcR/mZwLN0x5CmYIICmXfWgO1DG9GO8EJY=,tag:76r2cC12Qgtqd1f3Jv/ezA==,type:float]";
    secret-path =
      "ENC[AES256_GCM,data:2eqBSNnE2WOHjQ==,iv:xCiO/mexyu/TSf3NmAPN7kfEVyL2M7fPrXl0OhXrLQ4=,tag:jiNIp2ysJsofZXHf4pKvTw==,type:str]";
  };
  vaultwarden = {
    port =
      "ENC[AES256_GCM,data:Qp7vNQ==,iv:5zmKsZ8iS6WTm2VHDcWHOhi/yo6eqg6fINYhr/sNCNc=,tag:r3XDCFf5ZoMwDtDijL8oLA==,type:float]";
    subdomain =
      "ENC[AES256_GCM,data:9g==,iv:cM7r02RQ8o5MIBWBHaHIG4QHFX9F0AsbTDcsmFqAZbU=,tag:yUPvt4kg2EYZK/gUzkeCuA==,type:str]";
    websocket-port =
      "ENC[AES256_GCM,data:+yQ6aHA=,iv:VOGiZUguvi3e+yIr5Qb+7EyCNoZ/IJsmPu57hBhuRII=,tag:oYaMIlVXMtp4t35jPvcMCA==,type:float]";
  };
  vikunja = {
    subdomain =
      "ENC[AES256_GCM,data:0Q==,iv:uPbT5XeMLI2SSCgDY83T47lQZCwkH0ruSFtxwrN63Sw=,tag:QK0qDh2CAM8nFyChiJvpQA==,type:str]";
  };
}
