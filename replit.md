# Overview

This is a Roblox game project called "Glam (Roogle)" that implements a music management system with administrative controls and a monetization system for unblocking users. The project is built using Roblox's Lua scripting framework, with a clear separation between client-side (LocalScript) and server-side (ServerScript) logic.

The core features include:
- Admin panel for reviewing and approving/rejecting music requests
- Payment prompt system (100 Robux) for blocked users to gain access
- Music management system with categorization and author tracking
- Multi-part client scripts to work within Roblox's character limits

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Client-Server Architecture

**Problem:** Roblox games require clear separation between client and server logic for security and performance.

**Solution:** Implemented a split architecture where:
- Client-side code (LocalScripts) handles UI rendering, user interactions, and local state
- Server-side code (ServerScript) manages data validation, permissions, and cross-player communication

**Rationale:** This prevents client-side exploits and ensures game logic integrity. The server acts as the source of truth while clients handle presentation.

## Multi-Part Client Script System

**Problem:** Roblox imposes character limits on individual script files.

**Solution:** Client logic is divided into three coordinated LocalScripts:
1. **localscript1.lua** - Variable declarations and UI creation
2. **localscript2.lua** - Function definitions and business logic
3. **localscript3.lua** - Event connections and initialization

**Alternatives Considered:** 
- Single monolithic script (rejected due to Roblox limits)
- ModuleScripts (not chosen to maintain simplicity)

**Pros:** Works within platform constraints, maintains code organization
**Cons:** Requires careful coordination between files, potential for dependency issues

## Music Management System

**Problem:** Need a way for users to submit music and admins to review submissions before they appear in-game.

**Solution:** Implemented a request-approval workflow with:
- Music submission system storing: name, category, audio ID, author, timestamp
- Admin panel displaying pending requests
- Approve/reject actions that modify music database state

**Rationale:** Prevents inappropriate content and gives admins control over the game's music library.

## Monetization System

**Problem:** Need to monetize access for blocked users while maintaining fair gameplay.

**Solution:** Integrated Roblox's product purchase system:
- Blocked users receive a payment prompt (100 Robux)
- 5-second window to complete purchase
- Upon successful payment, user is unblocked

**Rationale:** Provides revenue stream while offering blocked users a second chance. The timer creates urgency without being predatory.

## UI Architecture

**Problem:** Complex UI with admin panels, music controls, and payment prompts requires organized structure.

**Solution:** All UI elements are created programmatically in localscript1.lua:
- Centralized UI creation ensures consistency
- Dynamic generation allows for easier updates
- Emoji integration for better visual communication

**Pros:** Single source of truth for UI, easier maintenance
**Cons:** Longer initial load time, more complex code

# External Dependencies

## Roblox Platform Services

**MarketplaceService**
- Purpose: Handle in-game purchases (100 Robux unblock fee)
- Integration: Server-side prompt display and purchase validation

**DataStoreService** (Implied)
- Purpose: Persist music requests, user block status, and approvals
- Usage: Store admin decisions and user data across sessions

## Roblox Audio System

**Sound/Audio APIs**
- Purpose: Play user-submitted music by audio ID
- Integration: Music player system uses Roblox's audio ID system
- Note: Audio IDs must be valid Roblox-approved assets

## Roblox Studio Placement

Scripts must be placed in specific locations:
- **LocalScripts (1, 2, 3, music):** StarterPlayer > StarterPlayerScripts
- **ServerScript:** ServerScriptService

This placement ensures proper execution context (client vs. server).