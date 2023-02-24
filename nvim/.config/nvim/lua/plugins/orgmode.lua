require("orgmode").setup_ts_grammar()
require("orgmode").setup({
    org_agend_files = { "~/notes/misc/**/*" },
    notifications = {
        enabled = true,
        cron_enabled = true,
        repeater_reminder_time = false,
    },
})
