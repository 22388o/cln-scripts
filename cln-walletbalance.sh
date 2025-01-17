#!/usr/bin/env bash

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Compute and display the wallet's current balance."
    echo "Usage: $(basename "$0")"
    exit
fi

confirmed_balance="0"
unconfirmed_balance="0"
outputs="$(lightning-cli listfunds | jq ".outputs")"
# lightning-cli listfunds | jq ".outputs" | jq -r ".[].status"
readarray -t output_statuses < <(jq -r ".[].status" <<< "$outputs")
readarray -t output_values < <(jq -r ".[].value" <<< "$outputs")
for i in $(seq 0 $(( ${#output_statuses[@]} - 1 )) ); do
    if [[ "${output_statuses[$i]}" == "confirmed" ]]; then
        confirmed_balance=$((confirmed_balance + ${output_values[$i]}))
    elif [[ "${output_statuses[$i]}" == "unconfirmed" ]]; then
        unconfirmed_balance=$((unconfirmed_balance + ${output_values[$i]}))
    fi
done
total_balance=$((confirmed_balance + unconfirmed_balance))

echo "{
    \"total_balance\": $total_balance,
    \"confirmed_balance\": $confirmed_balance,
    \"unconfirmed_balance\": $unconfirmed_balance
}"
