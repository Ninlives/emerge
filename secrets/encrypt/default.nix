{
  email =
    "ENC[AES256_GCM,data:Ja6NpMWPY9HboLNYgEcRtOPjUw==,iv:hx/1AtVmnAczP8/pXtVH/suyZzKHUsEZiHNwvFecZQo=,tag:bbuihujSm0QP/+38xYwTLA==,type:str]";
  hashed-password =
    "ENC[AES256_GCM,data:vRUczBgaKwYrVn2gRsvak+BQfaEdbhDImWACn2cT8ovRD4qf3CqqurEqXai1Fg9kDcUTLLAm2nYaTw4CMf0q8pLmhSF9/wllxnbX3DmSd/Ns/qopXI6/an1OigqoSK2Tbayc,iv:HjzDicUsIP6tYW30WCVP94m27r0A3cxy1Df57QxkQ+U=,tag:chJqZU0F7NUjIAGqanMy4g==,type:str]";
  reverse-proxy = {
    port =
      "ENC[AES256_GCM,data:pZ2cizM=,iv:w9h6Px2WKmALR+GsR2OGpdCJfR90SgD6/F+kitir5UI=,tag:M/iVbFmUxr5HMBqqf921Eg==,type:float]";
    secret-path =
      "ENC[AES256_GCM,data:cZc4MjlZ,iv:4Ow9bk54H9iP709PGguavbM6MXxJQw6aSx8qbkf5Lxc=,tag:IPSfZMViGxL/PDaLLHU5ng==,type:str]";
  };
  sops = {
    age = null;
    azure_kv = null;
    gcp_kms = null;
    hc_vault = null;
    kms = null;
    lastmodified = "2022-02-16T01:29:42Z";
    mac =
      "ENC[AES256_GCM,data:1wbhtjEuQ3ubvYbtZ29Js01UKutUBOIr1l6jkoJt+RUe4QU5p0SIbryBVXFInbPqDM1q5YaR9lnhmKoP6tdpre/4mJ71FXzqv1/567yRCzsQOOGBYMts6W0dq/EQvhOiFmo9bp1WqjrHmwOF3579Yp8xW84w0wuF64xz5qR9SFg=,iv:bIEBONji579iURpZz5zUg+tD1UPXMzMLIHIsX52mFWM=,tag:M49gcqSqYmW6I4InfRQ7+w==,type:str]";
    pgp = [
      {
        created_at = "2022-02-16T01:29:40Z";
        enc = ''
          -----BEGIN PGP MESSAGE-----

          hQIMAxZ0i0l3T3pJAQ//RnAjpicckMr1griK9kFXhQGh/7mxLkOioAoI5H1rWJG3
          HvdiTtbWi1qAOiHlmePXmIUqRuLG+LYQdH7zlbQC22z3Yj+lq7c1xSvUHgxNOx8U
          UEDTqlN73Eg5q8kcS9yY8AcUcfUkt7v3tuGOfvkmZbPSrtueglh0EKnqkvLzE4Lg
          0flI8MXx9aldIQm72HkmgUPw7QReXdA0QpiSG5bBHLMatlVKIeKSBrC52CtNatqn
          NwrVjeuN4rW48UH7NMkfdU8MlC5/rf9urAV8qa+j+XQ0EZsWnItM5VTwuAslrrEi
          pXvQulQM8g+D1ivnLNagSAYK2TOAxOBVUMqpuQRCxdxQsLic8MLPqxKZtw/kGa57
          +2ynmmJuy6vnRfW9MawxvPsFOppBqMXXh+5JCNeB94Vt38uIqdwBe4paKpP8EM64
          EBqkc/wMhLm0adH1EvzmQIAb6ekCBzUjXekOPKS4plenrJLkTljjsiWGn9tPLIYy
          bX7pFLqL3fgD/rSu0Epix5gUpx5L2yS5PoXkZuFh3yoYE8QHO42ZS9eU4vO5jjlO
          xyuMBHashcilEslS8FxtTv4cOU3Lziyn9+SW2UW4B5U90yfoxSvf8lySMuQtUuh9
          J3Ib7msymBWkurxzZDeKC77Yn2VBDaRnnrBnn0QVJnVQC8qN428i9XIweLRZjs7S
          WAERDYh/O3/yuyq+XR4syRkbvbvtbBsk/m6ayx9r4HpPMKgnOeAYVp/q6V8/qEXj
          3hX7wsjeOKhqirmJFKw8tiCRi+KyEpL4C6lZykeLxtRFOkSAgfB1qCQ=
          =6x5g
          -----END PGP MESSAGE-----
        '';
        fp = "DBF39C1CFAC86760C31C66F216748B49774F7A49";
      }
      {
        created_at = "2022-02-16T01:29:40Z";
        enc = ''
          -----BEGIN PGP MESSAGE-----

          hQIMA3aDhypj51MeAQ/+PrEXvDSl+65ZewXujt2L8O7CshWs59PJgjUtQSEqVEYh
          2GBPEhDXW2xpvELbGqtvkIm2WFZDHQdtN3yU1hBJPSd1MU5pjIp6ZTLcLq0HcMYc
          dfucSvj3NGy30UAD+iTSDQcI73/fCih/kLouzP/QVCuo7eQ0IShnvUIeI7+Mn5YH
          GRo0Zf0JFplcWNS2N0D4FM2FPXIbIL/TBAMSFV9paX7YQxVXMMs6AFKlo5nioiFC
          d/qMpZzQ3km4zK8UqzMXqylqnH63S+81/Zy8EpTcAplcjOMWg+Z5g0n1Q0YijFLz
          hVYefbtlEl38vS2lsFlybR5aJjZFysaf88/bqi6G2NncCD2mlE5Mr/QtRQeSiL+a
          syRlhi/47JuWOgHBtIYMPT0f7j7hVZ+FwZ6Ak1c23+ZSh16qowWBog38HDW7NjRb
          MBu1JQasa2CSmbAruBFP62GttY5quw6Ju9KCxwx65vTKJa3/dQ60nIQ0tyPmn+pi
          j+W6TGDu1K3+h8f14MW16Cg53e93yLIkMfHqKbduDqK185yyXmUdKKZpLvwaBlqf
          uMMoPjGsAciQT4xOHjpdH1gdZtZTrsSIIJI+xaozwQmoQUyv1ZTZQYWEyFiFl4Pt
          ZEj59dOsL09hyR8k5Q71g8BDdpPZDNjHK8eS9t/Va10MfwaePlLdwAkSh+r8CifS
          WAG+2g19xsfQQHoLZ5va/KQlQsQzuA5fiKhKRBJZJr/PfREYQXr5UglM953H4BpJ
          tVlz0oVgkSkMugy4y//aQEaSAFD8mX14Jfe36h9C4ORNHLu8DCt9kCw=
          =rRY4
          -----END PGP MESSAGE-----
        '';
        fp = "4AB0D407666087F0106B49527683872A63E7531E";
      }
    ];
    unencrypted_suffix = "_unencrypted";
    version = "3.7.1";
  };
  ssh = {
    auth =
      "ENC[AES256_GCM,data:UKihROO2TBAQ2fyD+ipyVbIqzWs1FT5js9R/TX/2brBRy3FuQ4p4d3c6e0KBDpwJWGnxFgNyGSwB8+sJ5AI0sY8fJJ8HJwI1HZOcXuN4K0SJShmUkGjrkQw4K+59c3LUPJK0GQ==,iv:T+B0K0avt9o3YIv5ke9MbWkGTA5jiJS1mcQxYqNJSpI=,tag:9kAoSkr9PVEXJDLZHuLlLQ==,type:str]";
    port =
      "ENC[AES256_GCM,data:LU8qbAg=,iv:WU6bvd5T6ice++/JSxkH8C0TL3cRTROz1/Uci5VyZoQ=,tag:AIRP1QtWaC+MqOrY+r11uQ==,type:float]";
  };
  syncthing = {
    local = {
      id =
        "ENC[AES256_GCM,data:SfyZp/gMG9MD4xm5I0mwn8AwCCDeZesSnmmR7euQthIHu3fxssGM+DRsNZcuFLREv07OiDzz9eDK6XYCV/7k,iv:wv2znO/qoMsZSFr748KHEC+3tQnbw/dqmHhBp2Jedg8=,tag:asBT3y9/lofEk7qRObdRxg==,type:str]";
    };
    server = {
      id =
        "ENC[AES256_GCM,data:SfPDLBeKVIaz8vnpCRlMMwwY61J3/kk+O5Tg147ujpM4JPvAaSkWmHVGWGmvhO/uNXu/ezzpAC49HTU4ShPu,iv:ao8VUgAFeE+I8FLLu+ECT3QtA0YTmd97SfYLug+k/BM=,tag:Vjp/xiEaAxMCjbaXljsGsw==,type:str]";
    };
  };
  v2ray = {
    host =
      "ENC[AES256_GCM,data:qUzgiQJNMrWyHv1vggft8Q==,iv:uWRDLuZCPSg3lxSjBWgdFhBBW0NcRZUtAUy2eLeMsWg=,tag:TkklQiWOSo+MVqYTMDikVg==,type:str]";
    internal-port =
      "ENC[AES256_GCM,data:HmG9O88=,iv:0+CpHkKgDFMgB/QTIB4xx5lCHqdiqmFWo0Kn0RR7l9Q=,tag:D7ldux+ZXNG8YgM95B56og==,type:float]";
    root-location =
      "ENC[AES256_GCM,data:wvpZ5G7zU9NqxpwT,iv:lELJr6IlrddoY+/o3hUAjSVpnl4TPT0Vh33g2ffqpq8=,tag:d6Q0gtD47cX+JVuMFHVgjg==,type:str]";
    secret-path =
      "ENC[AES256_GCM,data:iMuh8uarUD6SLQ==,iv:AEkPKomc+fZUwjp8Mbk/aTPcNshMrmJ+mWoRgm+mkqc=,tag:rYGMP/3jlNlocHV/3fSaQQ==,type:str]";
  };
  vaultwarden = {
    host =
      "ENC[AES256_GCM,data:JB31t2gJCnm1TrCh/QHA+A==,iv:jkmNGRCIVut18NYQpXFIAo1ypsaf0/rEgL78vdT0HgY=,tag:pOClEZr3t2vWykmOKFCTEw==,type:str]";
    port =
      "ENC[AES256_GCM,data:xIIAbY4=,iv:uwz/hUebX5RiPDpNjg5EYI10VCjb1sqjhz6m64n1Lu4=,tag:5B86rcP8xdXfd0mP+/Xkaw==,type:float]";
    websocket-port =
      "ENC[AES256_GCM,data:kjGA7Sk=,iv:fLEiKmnNZDQsn1tm/pTBnBOwWOjXHg+ifumkNziiJW8=,tag:kEdCdKe7FhKlml99/DSUWg==,type:float]";
  };
}
