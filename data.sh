#!/bin/bash

API_KEY=$GEMINI_API_KEY
LOGFILE="ai-devops.log"

if [ -z "$API_KEY" ]; then
  echo "❌ GEMINI_API_KEY not set"
  exit 1
fi

echo "===================================="
echo "🚀 AI DevOps Assistant Started"
echo "Type 'exit' to quit"
echo "===================================="

while true
do
    echo ""
    echo "Enter task for AI:"
    read PROMPT

    if [[ "$PROMPT" == "exit" ]]; then
        echo "👋 Exiting..."
        break
    fi

    echo "🤖 Asking Gemini..."

    RESPONSE=$(curl -s \
      -H "Content-Type: application/json" \
      -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$API_KEY" \
      -d "{
        \"contents\": [{
          \"parts\": [{
            \"text\": \"Convert this request into ONLY a single safe Linux command without explanation: $PROMPT\"
          }]
        }]
      }")

    COMMAND=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

    if [[ -z "$COMMAND" || "$COMMAND" == "null" ]]; then
        echo "❌ AI did not return a command"
        echo "$(date) | ERROR | $PROMPT" >> $LOGFILE
        continue
    fi

    echo ""
    echo "💡 AI Suggested Command:"
    echo "$COMMAND"

    # Security filter
    if [[ "$COMMAND" == "rm" || "$COMMAND" == "shutdown" || "$COMMAND" == "reboot" || "$COMMAND" == ":(){:|:&};:" ]]; then
        echo "❌ Dangerous command blocked!"
        echo "$(date) | BLOCKED | $COMMAND" >> $LOGFILE
        continue
    fi

    echo ""
    echo "⚡ Executing Command..."
    echo "$(date) | PROMPT: $PROMPT | CMD: $COMMAND" >> $LOGFILE

    OUTPUT=$(eval "$COMMAND" 2>&1)

    echo ""
    echo "📤 Command Output:"
    echo "$OUTPUT"

    echo "$(date) | OUTPUT: $OUTPUT" >> $LOGFILE

    echo "----------------------------------------"
done
