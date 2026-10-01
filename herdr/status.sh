#!/bin/bash
# tab_bar_right 用のステータス出力 (tmux の tmux-cpu / tmux-weather 相当)
case "${1:-}" in
  cpu)
    top -l 1 -n 0 | awk '/CPU usage/ { printf "CPU %.0f%%", $3 + $5 }'
    ;;
  ram)
    vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
      /page size of/ { ps = $8 }
      /Pages active/ { a = $3 }
      /Pages wired/ { w = $4 }
      /occupied by compressor/ { c = $5 }
      END { printf "RAM %.0f%%", (a + w + c) * ps * 100 / total }'
    ;;
  weather)
    # %l:+%c+%t (Tokyo, metric)。取得失敗時は何も出さない
    curl -fsS --max-time 3 'https://wttr.in/Tokyo?format=%l:+%c+%t&m' 2>/dev/null
    ;;
esac
