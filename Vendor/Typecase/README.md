# Vendored Typecase snapshot

LUFF-owned first-party components copied with owner approval for KVM Display Sync.
This is a limited source snapshot, not the complete Typecase repository. It is
shipped under KVM Display Sync's MIT license. Typecase itself remains private.

Origin: luff-llc/typecase at `36ef6a1b198331e77e6308d117aef4b2778b5d87`.
`UPSTREAM.json` records original paths, SHA-256 values, and local adaptations.
Original Marginalia provenance comments are retained.

Adaptations: omit upstream standalone previews/localization-only fixtures;
extract ReadingFace/ReadingTypeface needed by Theme; add a static linear-gradient
fallback on macOS 14. The mesh room and native glass/material behavior remain on
supported systems. The host keeps the room still for this background utility.

Do not symlink to a developer checkout. Update deliberately from a pinned upstream
revision, review adaptations and the host screen, and update UPSTREAM.json. Replace
this directory with a versioned dependency when Typecase distribution is settled.
