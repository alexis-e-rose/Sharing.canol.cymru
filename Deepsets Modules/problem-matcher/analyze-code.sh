#!/bin/bash

# Problem Matcher Analysis Script - Deepsets Module
# Creates timestamped analysis reports with automatic archiving
# Part of Sharing.canol.cymru Deepsets Modules

set -e  # Exit on error

# Configuration
MODULE_DIR="Deepsets Modules/problem-matcher"
REPORTS_DIR="$MODULE_DIR/reports"
ARCHIVE_DIR="$REPORTS_DIR/archive"
MAX_REPORTS=5
ARCHIVE_DAYS=7

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure we're in project root
if [[ ! -d "Sharing" ]]; then
    echo -e "${RED}ERROR: Must run from project root directory${NC}"
    echo "Expected to find 'Sharing' directory"
    exit 1
fi

# Function to generate timestamp (following Deepsets protocol)
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

get_filename_timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

get_archive_month() {
    date +"%Y-%m"
}

# Function to create directories
ensure_directories() {
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$ARCHIVE_DIR"
    mkdir -p "$ARCHIVE_DIR/$(get_archive_month)"
}

# Function to archive old reports
archive_old_reports() {
    local force_archive=${1:-false}
    local archived_count=0
    
    if [[ ! -d "$REPORTS_DIR" ]]; then
        return 0
    fi
    
    # Archive reports older than ARCHIVE_DAYS
    if [[ "$force_archive" == "true" ]] || find "$REPORTS_DIR" -name "problems_report_*.txt" -mtime +$ARCHIVE_DAYS | grep -q .; then
        echo -e "${YELLOW}📦 Archiving old reports...${NC}"
        
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                local file_month=$(echo "$filename" | sed -n 's/problems_report_\([0-9]\{4\}-[0-9]\{2\}\)-.*/\1/p')
                
                if [[ -n "$file_month" ]]; then
                    mkdir -p "$ARCHIVE_DIR/$file_month"
                    mv "$file" "$ARCHIVE_DIR/$file_month/"
                    
                    # Also move corresponding JSON file if it exists
                    local json_file="${file%.txt}.json"
                    if [[ -f "$json_file" ]]; then
                        mv "$json_file" "$ARCHIVE_DIR/$file_month/"
                    fi
                    
                    archived_count=$((archived_count + 1))
                    echo -e "  📁 Archived: $filename"
                fi
            fi
        done < <(find "$REPORTS_DIR" -maxdepth 1 -name "problems_report_*.txt" -mtime +$ARCHIVE_DAYS -print0)
    fi
    
    # Archive excess reports if more than MAX_REPORTS
    local report_count=$(find "$REPORTS_DIR" -maxdepth 1 -name "problems_report_*.txt" | wc -l)
    if [[ $report_count -gt $MAX_REPORTS ]]; then
        echo -e "${YELLOW}📦 Too many reports ($report_count), archiving oldest...${NC}"
        
        local excess=$((report_count - MAX_REPORTS))
        find "$REPORTS_DIR" -maxdepth 1 -name "problems_report_*.txt" -printf '%T@ %p\n' | \
        sort -n | \
        head -n $excess | \
        while read timestamp file; do
            local filename=$(basename "$file")
            local file_month=$(echo "$filename" | sed -n 's/problems_report_\([0-9]\{4\}-[0-9]\{2\}\)-.*/\1/p')
            
            if [[ -n "$file_month" ]]; then
                mkdir -p "$ARCHIVE_DIR/$file_month"
                mv "$file" "$ARCHIVE_DIR/$file_month/"
                
                # Also move corresponding JSON file if it exists
                local json_file="${file%.txt}.json"
                if [[ -f "$json_file" ]]; then
                    mv "$json_file" "$ARCHIVE_DIR/$file_month/"
                fi
                
                archived_count=$((archived_count + 1))
                echo -e "  📁 Archived: $filename"
            fi
        done
    fi
    
    if [[ $archived_count -gt 0 ]]; then
        echo -e "${GREEN}✅ Archived $archived_count reports${NC}"
    fi
}

# Function to update latest symlink
update_latest_symlink() {
    local latest_file="$1"
    local symlink_path="$REPORTS_DIR/latest_report.txt"
    
    if [[ -f "$latest_file" ]]; then
        rm -f "$symlink_path"
        ln -s "$(basename "$latest_file")" "$symlink_path"
        echo -e "${GREEN}🔗 Updated latest_report.txt symlink${NC}"
    fi
}

# Function to run the analysis
run_analysis() {
    local timestamp=$(get_timestamp)
    local file_timestamp=$(get_filename_timestamp)
    local txt_file="$REPORTS_DIR/problems_report_${file_timestamp}.txt"
    local json_file="$REPORTS_DIR/problems_report_${file_timestamp}.json"
    
    echo -e "${BLUE}🔍 Running Problem Matcher Analysis${NC}"
    echo -e "Timestamp: ${timestamp}"
    echo -e "Output: $(basename "$txt_file")"
    echo ""
    
    # Run the PHP analysis script
    if [[ ! -f "$MODULE_DIR/problem_matcher.php" ]]; then
        echo -e "${RED}ERROR: problem_matcher.php not found in $MODULE_DIR${NC}"
        exit 1
    fi
    
    # Modify the problem matcher to use our specific output files
    php -d auto_prepend_file= -d auto_append_file= << 'EOF'
<?php
// Inline execution of problem matcher with custom output paths
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get output paths from environment or use defaults
$txt_file = getenv('ANALYSIS_TXT_FILE') ?: 'problems_report.txt';
$json_file = getenv('ANALYSIS_JSON_FILE') ?: 'problems_report.json';

// Include the problem matcher class
require_once('Deepsets Modules/problem-matcher/problem_matcher.php');

// Run analysis
$matcher = new ProblemMatcher('./Sharing');
$problems = $matcher->analyze();

// Generate outputs
$txt_output = $matcher->outputText();
$json_output = $matcher->outputJson();

// Write to specified files
file_put_contents($txt_file, $txt_output);
file_put_contents($json_file, $json_output);

// Output summary to console
echo $txt_output;

echo "\n" . str_repeat("=", 50) . "\n";
echo "📊 ANALYSIS SUMMARY\n";
echo str_repeat("=", 50) . "\n";
echo "Reports saved to:\n";
echo "- " . basename($txt_file) . " (human readable)\n";
echo "- " . basename($json_file) . " (structured data)\n";
echo "\nTotal Issues Found: " . count($problems) . "\n";

$severity_counts = [];
foreach ($problems as $problem) {
    $severity = $problem['severity'];
    $severity_counts[$severity] = ($severity_counts[$severity] ?? 0) + 1;
}

foreach ($severity_counts as $severity => $count) {
    echo "- $severity: $count issues\n";
}
?>
EOF
    
    # Export file paths for PHP script
    export ANALYSIS_TXT_FILE="$txt_file"
    export ANALYSIS_JSON_FILE="$json_file"
    
    # Run the analysis
    php -f /dev/stdin << 'EOF'
<?php
$txt_file = getenv('ANALYSIS_TXT_FILE');
$json_file = getenv('ANALYSIS_JSON_FILE');

require_once('Deepsets Modules/problem-matcher/problem_matcher.php');

$matcher = new ProblemMatcher('./Sharing');
$problems = $matcher->analyze();

$txt_output = $matcher->outputText();
$json_output = $matcher->outputJson();

file_put_contents($txt_file, $txt_output);
file_put_contents($json_file, $json_output);

echo $txt_output;
echo "\n" . str_repeat("=", 50) . "\n";
echo "📊 ANALYSIS SUMMARY\n";
echo str_repeat("=", 50) . "\n";
echo "Reports saved to:\n";
echo "- " . basename($txt_file) . " (human readable)\n";
echo "- " . basename($json_file) . " (structured data)\n";
echo "\nTotal Issues Found: " . count($problems) . "\n";

$severity_counts = [];
foreach ($problems as $problem) {
    $severity = $problem['severity'];
    $severity_counts[$severity] = ($severity_counts[$severity] ?? 0) + 1;
}

foreach ($severity_counts as $severity => $count) {
    echo "- $severity: $count issues\n";
}
?>
EOF
    
    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Analysis completed successfully${NC}"
        update_latest_symlink "$txt_file"
        return 0
    else
        echo -e "\n${RED}❌ Analysis failed${NC}"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Problem Matcher Analysis Tool - Deepsets Module"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no options)      Run analysis with timestamped output"
    echo "  --archive-old     Archive reports older than $ARCHIVE_DAYS days"
    echo "  --archive-all     Archive all but latest $MAX_REPORTS reports"
    echo "  --list-reports    List all current reports"
    echo "  --list-archived   List archived reports"
    echo "  --help           Show this help message"
    echo ""
    echo "Output Location: $REPORTS_DIR/"
    echo "Archive Location: $ARCHIVE_DIR/"
    echo ""
    echo "Integration:"
    echo "  1. Run this script before AI conversations"
    echo "  2. Attach the latest report file to your chat"
    echo "  3. Reference specific line numbers in your prompts"
}

# Function to list reports
list_reports() {
    echo -e "${BLUE}📋 Current Reports${NC}"
    if [[ -d "$REPORTS_DIR" ]]; then
        find "$REPORTS_DIR" -maxdepth 1 -name "problems_report_*.txt" -printf '%TY-%Tm-%Td %TH:%TM  %f\n' | sort -r
        echo ""
        local count=$(find "$REPORTS_DIR" -maxdepth 1 -name "problems_report_*.txt" | wc -l)
        echo "Total: $count reports"
        
        if [[ -L "$REPORTS_DIR/latest_report.txt" ]]; then
            local target=$(readlink "$REPORTS_DIR/latest_report.txt")
            echo -e "Latest: ${GREEN}$target${NC}"
        fi
    else
        echo "No reports directory found"
    fi
}

# Function to list archived reports
list_archived() {
    echo -e "${BLUE}📦 Archived Reports${NC}"
    if [[ -d "$ARCHIVE_DIR" ]]; then
        find "$ARCHIVE_DIR" -name "problems_report_*.txt" -printf '%TY-%Tm-%Td %TH:%TM  %P\n' | sort -r
        echo ""
        local count=$(find "$ARCHIVE_DIR" -name "problems_report_*.txt" | wc -l)
        echo "Total: $count archived reports"
    else
        echo "No archive directory found"
    fi
}

# Main execution
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --archive-old)
            ensure_directories
            archive_old_reports true
            exit 0
            ;;
        --archive-all)
            ensure_directories
            archive_old_reports true
            exit 0
            ;;
        --list-reports)
            list_reports
            exit 0
            ;;
        --list-archived)
            list_archived
            exit 0
            ;;
        "")
            # Standard analysis run
            ensure_directories
            archive_old_reports false
            run_analysis
            exit $?
            ;;
        *)
            echo -e "${RED}ERROR: Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 