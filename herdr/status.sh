#!/bin/bash
# tab_bar_right 用のステータス出力 (tmux の tmux-cpu / tmux-weather 相当)
case "${1:-}" in
  cpu)
    # 1回目のサンプルは起動時からの累積なので、2回目 (直近の区間) を使う
    top -l 2 -n 0 -s 1 | awk '/CPU usage/ { u = $3 + $5 } END { printf "CPU %.0f%%", u }'
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
