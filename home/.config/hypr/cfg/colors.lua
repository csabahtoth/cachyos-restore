-- ━━━━━━━━━━━━━━━━ Colors ━━━━━━━━━━━━━━━━
-- Static Tokyo-Night border colors, matching Noctalia's actual live active
-- scheme (confirmed via `noctalia msg color-scheme-get` -> "builtin
-- Tokyo-Night", cross-checked at the time against the legacy noctalia-shell
-- package's bundled Tokyo-Night.json dark palette; that package has since
-- been uninstalled, see project CLAUDE.md). Not synced automatically —
-- Noctalia's dynamic
-- color-application paths (native "hyprland" template, apply-colors.sh
-- hook) were both broken and have been removed in favor of this static
-- approach, matching upstream's model. Update these constants by hand if
-- the active color scheme changes.

PRIMARY   = "rgb(7aa2f7)"
SURFACE   = "rgb(1a1b26)"
SECONDARY = "rgb(bb9af7)"
ERROR     = "rgb(f7768e)"
