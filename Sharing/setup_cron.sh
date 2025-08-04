#!/bin/bash
# Phase 2 Cron Job Setup Script

echo "🕐 Setting up cron job for Phase 2 notifications..."

# Get the current directory
CURRENT_DIR=$(pwd)
CRON_FILE="$CURRENT_DIR/Sharing/cron_notifications.php"

echo "📂 Cron script location: $CRON_FILE"

# Check if file exists
if [ ! -f "$CRON_FILE" ]; then
    echo "❌ Error: $CRON_FILE not found"
    exit 1
fi

# Make executable
chmod +x "$CRON_FILE"
echo "✅ Made cron script executable"

# Create log directory
mkdir -p logs
echo "✅ Created logs directory"

# Generate crontab entry
CRON_ENTRY="*/15 * * * * /usr/bin/php $CRON_FILE >> $CURRENT_DIR/logs/notifications.log 2>&1"

echo ""
echo "📋 Suggested crontab entry:"
echo "----------------------------------------"
echo "$CRON_ENTRY"
echo "----------------------------------------"
echo ""
echo "To install, run:"
echo "  crontab -e"
echo "Then add the above line."
echo ""
echo "Or run this command to add it automatically:"
echo "  (crontab -l 2>/dev/null; echo \"$CRON_ENTRY\") | crontab -"
echo ""
echo "✅ Cron setup script complete!" 