#!/bin/bash

if [ -p /dev/stdin ]; then
  awk '
    $8 != "logged" {
      print $3, $4, $5, $6, $8
    }
  ' - | sed 's/:/ /g' | awk '
    {
      start = rounding($4, $5);
      end = rounding($6, $7);

      key = $1 " " pad($3)

      s[key] = s[key] ? s[key] : "23:59";
      e[key] = e[key] ? e[key] : "00:00";

      if (start < s[key]) s[key] = start;
      if (end > e[key]) e[key] = end;
    }

    END {
      for(key in s) { print $2, key " ", s[key], e[key] }
    }

    function rounding(h, m) {
      if (!h || !m) return;

      mod = 15; t = 10;
      r = m % mod;
      m = r >= t ? m + (mod - r) : m - r;

      if (m >= "60") {
        h = h + 1;
        m = "0";
      }

      return h ":" pad(m);
    }

    function pad(m) {
      return (m + 0) < 10 ? "0" m : m;
    }
  ' | sort -t " " -nk3

  exit 0
else
  echo 'Usage: `last | grep Jan | ./worktime.sh`'

  exit 1
fi
