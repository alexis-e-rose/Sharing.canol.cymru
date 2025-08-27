<?php
// Centralized feature flags for incremental rollout
// Usage: if (is_feature_enabled('sales_flow')) { ... }

if (!isset($FEATURE_FLAGS)) {
    $FEATURE_FLAGS = [
        'sales_flow' => false,
        'donation_ledger' => false,
        'donation_statements' => false,
        'community_freeze' => false,
        'enhanced_visibility' => false,
        'listing_enhancements' => false
    ];
}

function is_feature_enabled($flag_name) {
    global $FEATURE_FLAGS;
    return isset($FEATURE_FLAGS[$flag_name]) ? (bool)$FEATURE_FLAGS[$flag_name] : false;
}

?>

