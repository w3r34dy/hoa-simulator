# Violation Discovery Loop

This note captures the first gameplay system we want to prove: players patrol a shared HOA neighborhood, find violations as they appear over time, call them out through an interaction, and earn rewards for serving the HOA.

## Core Idea

Players walk or drive around the HOA community looking for visible rule violations. The game continuously creates violations on houses, yards, vehicles, or neighborhood objects so patrollers always have something to discover.

This is the first part of the larger HOA loop:

```text
Patrol neighborhood
-> Discover violation
-> Interact to call it out / write paperwork
-> Earn rewards
-> More violations appear over time
```

## Initial Violation Examples

- Grass too tall
- Trash cans left out
- Wrong mailbox color
- Unauthorized decorations
- Unapproved shed
- Parking violations
- Political signs
- Holiday decorations left up

## Step 1 Scope

For the first playable version, we should prove the mechanic with one or a few house assets.

The system should be able to:

- choose an eligible house or target object
- apply a visible violation to it
- let a player discover it through proximity, interaction, or inspection
- reward the player for correctly calling it out
- clear or resolve the violation
- generate new violations over time

The first visual implementation can be simple. For example, changing the color of an existing part on the house is enough to prove the code is working.

The first reward loop can be equally simple:

```text
Find visible violation
-> interact with the target
-> short paperwork/citation action
-> receive money, XP, or reputation
```

## First Mailbox Prototype Setup

The first active violation is `WrongMailboxColor`. It uses Studio attributes on mailbox models and on the parts of each mailbox that should change color.

```text
Mailbox model:
HOAMailbox = true

Color-changing mailbox parts:
HOAMailboxColorPart = true
```

Each mailbox can have multiple color-changing parts. The handler will recolor every descendant part marked with `HOAMailboxColorPart = true`.

Configured violation ids:

```text
GrassTooTall
TrashCansOut
WrongMailboxColor
UnauthorizedDecorations
UnapprovedShed
ParkingViolation
PoliticalSign
HolidayDecorationsExpired
```

For now, blue mailboxes are banned. When the server starts, mailbox targets are assigned random allowed colors. When the server activates a `WrongMailboxColor` violation, it changes one mailbox to a banned color and adds a `ProximityPrompt` named `HOAInspectionPrompt`. A player can interact with the prompt to write the citation, earn rewards, and clear the violation.

When the mailbox violation is resolved, the handler repaints the mailbox to an allowed color. Later handlers can use their own setup, such as showing tall grass, moving trash cans, toggling decoration models, or spawning signs.

## Time and Spawn Quotas

The server runs an accelerated HOA calendar through `TimeService`:

```text
1 in-game day = 5 real minutes
1 in-game week = 35 real minutes
Day phases = Morning, Afternoon, Evening, Night
```

The violation system now maintains per-violation quotas instead of picking one global random violation. Each definition has:

```text
TargetActive
Availability
```

Current setup:

```text
WrongMailboxColor: keep 4 active when targets exist
TrashCansOut: keep 3 active only outside the trash window
GrassTooTall: unavailable for now
```

Trash cans use a scheduled visibility window:

```text
Tuesday Evening through Thursday Morning:
all trash cans are visible, old trash violations are cleared, and trash citations cannot spawn

Thursday Afternoon until the next trash window:
inactive cans are stored, and the quota manager can keep TrashCansOut violations active
```

Studio trash can setup:

```text
Trash can model or part:
HOATrashCan = true
```

When a trash citation is resolved, that can is stored. The quota manager may later expose another stored can as a fresh `TrashCansOut` violation, creating the illusion that another household left cans out after pickup.

## Design Goals

- Violations should be easy to add later without rewriting the whole system.
- Houses and targets should be configurable from Studio where possible.
- The map should be able to grow without hardcoding every house into scripts.
- Multiple players should be able to patrol the same neighborhood.
- The system should avoid giving duplicate rewards for the same violation.
- Visible changes should make the violation understandable without needing complex UI at first.
- Some violations should be worth more than others.
- Players should be able to learn active HOA policies from a menu.
- Players should be able to read current policies from a menu so they can figure out what counts as a violation.

## Likely Technical Direction

Use a data-driven violation system:

```text
Violation definition
-> target type
-> visual change
-> reward values
-> spawn rules
-> policy requirements
```

Use Studio tags, attributes, or naming conventions on map objects:

```text
House model
Mailbox part
Grass part
Trash can model
Parking spot
Decoration point
```

Then the server can find eligible targets and apply violations without depending on one exact map layout.

## Policy Menu

Players should have access to a read-only menu that explains the current HOA policies. This is part of Step 1 because players need a way to learn what counts as a violation.

Example policy entries:

```text
Mailbox colors allowed: black, white, gray
Grass height limit: short
Trash cans must be hidden after pickup
Holiday decorations expire after event season
Political signs are restricted
```

For Step 1, policies do not need to change during the server. The menu can simply display the current rules from the same data used by the violation system.

The important rule is that policy changes must be readable in the menu before players are punished or expected to enforce them.

Policy-changing mechanics, board votes, and server-specific rule changes are later features. When added, they should update the same policy data that the violation system and menu already use.

## Multiplayer Notes

The neighborhood is shared, but rewards can be individual.

Possible rule:

```text
First player to discover a violation gets discovery credit.
Other jobs can still interact with the case later.
```

For Step 1, we only need discovery credit and basic rewards. Later systems can add citations, appeals, resident reactions, job roles, and case resolution.

## Open Questions

- What does the first house asset contain?
- Which part should be the first violation target?
- Should violations be obvious visually, subtle, or both depending on difficulty?
- Should players need a tool, proximity prompt, camera, or simple interaction key to inspect?
- What rewards should each first violation type pay?
- How long should a violation remain active before changing or expiring?
- Should spawn timing be global, per house, or per neighborhood area?
- What policy information should be visible in the first read-only policy menu?
