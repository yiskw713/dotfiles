#!/bin/bash
# ペイン名が未設定なら、同じタブ内で使っていない最小の番号で "pane N" と付ける
# タブ名が既定の数字のままなら "tab N" にする
# .zshrc から herdr 内のシェル起動時に呼ぶ
[ -n "$HERDR_PANE_ID" ] || exit 0
tab=$(herdr tab list | jq -c --arg id "$HERDR_TAB_ID" '.result.tabs[] | select(.tab_id == $id)')
label=$(jq -r '.label' <<<"$tab")
[[ "$label" =~ ^[0-9]+$ ]] && herdr tab rename "$HERDR_TAB_ID" "tab $(jq -r '.number' <<<"$tab")" >/dev/null
panes=$(herdr pane list | jq -c --arg tab "$HERDR_TAB_ID" '[.result.panes[] | select(.tab_id == $tab)]')
[ "$(jq -r --arg id "$HERDR_PANE_ID" '.[] | select(.pane_id == $id) | .label // empty' <<<"$panes")" ] && exit 0
used=$(jq -r '.[].label // empty' <<<"$panes")
n=1
while grep -qx "pane $n" <<<"$used"; do n=$((n + 1)); done
herdr pane rename "$HERDR_PANE_ID" "pane $n"
