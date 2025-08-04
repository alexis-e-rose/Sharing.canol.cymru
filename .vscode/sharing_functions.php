<?php
/**
 * IntelliSense stub file for Sharing Canol Cymru custom functions
 * This file helps IntelliSense recognize custom functions defined in include files
 * DO NOT EXECUTE - This is for IDE assistance only
 */

// Functions from includes/miscfunctions.inc
function qq(string $str): string { return ''; }
function cell2(string $str1, string $str2): string { return ''; }
function cell3(string $str1, string $str2, string $str3): string { return ''; }
function cell4(string $str1, string $str2, string $str3, string $str4): string { return ''; }
function cell5(string $str1, string $str2, string $str3, string $str4, string $str5): string { return ''; }
function cell6(string $str1, string $str2, string $str3, string $str4, string $str5, string $str6): string { return ''; }
function qecho(string $str1, string $str2): void {}

// Functions from includes/booking_functions.inc
function check_booking_availability(int $thing_ID, string $start_date, string $end_date): bool { return true; }
function get_booking_status_text(int $status): string { return ''; }
function get_booking_status_color(int $status): string { return ''; }
function create_booking_request(int $thing_ID, int $member_ID, string $start_date, string $end_date, string $notes = ''): int|false { return 1; }
function update_booking_status(int $booking_ID, int $new_status, int $member_ID): bool { return true; }
function get_member_bookings(int $member_ID, bool $as_owner = false): array { return []; }
function get_due_returns(int $days_ahead = 1): array { return []; }
function format_display_date(string $date): string { return ''; }
function calculate_loan_cost(float $thing_price, int $days): float { return 0.0; }
function generate_availability_calendar(int $thing_ID, ?int $month = null, ?int $year = null): string { return ''; }

// Functions from includes/notification_functions.inc
function create_notification(int $member_ID, string $type, string $title, string $message, ?string $data = null, int $priority = 3): int|false { return 1; }
function get_member_notifications(int $member_ID, int $limit = 10, bool $unread_only = false): array { return []; }
function mark_notification_read(int $notification_ID, int $member_ID): bool { return true; }
function get_unread_notification_count(int $member_ID): int { return 0; }
function process_pending_notifications(int $limit = 50): array { return []; }
function send_email_notification(array $notification_data): bool { return true; }
function get_notification_template(string $template_name): string { return ''; }
function replace_template_variables(string $template_text, array $notification_data): string { return ''; }
function get_notification_type_info(string $type): array { return []; }
function format_notification_row(array $notification): string { return ''; }
function time_ago(string $datetime): string { return ''; }

// JavaScript function that appears in PHP - exclude from checking
// function calculateCost() - This is JavaScript, not PHP

// Database connection variables (from includes/connect.inc)
/** @var mysqli $mysqli */
global $mysqli; 