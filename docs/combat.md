## Combat System

### Core Loop
- Encounter starts → roll initiative → turns proceed in order.
- On your turn: move, use one ability, and/or item depending on class rules.
- End conditions: all enemies defeated or party defeated.

### Initiative
- Base from Speed + modifiers (buffs/debuffs, terrain, relics).
- Turn preview UI shows upcoming order; some abilities can reorder.

### Actions
- Movement: grid or free tiles (TBD in prototype), affected by terrain.
- Abilities: short-cooldown skills and longer-cooldown ultimates.
- Items: consumables with tactical effects.

### Status Effects (Examples)
- Burn (DoT, reduces healing), Poison (DoT, ignores armor), Stun (skip turn), Vulnerable (+X% damage taken), Slow (initiative penalty), Weaken (reduced damage), Silence (no spells).

### Terrain & Hazards
- Cover (ranged damage reduction), Choke Points (movement constraints), Fire tiles (apply Burn), Poison pools, Ice (slip/Slow), Time rifts (randomize initiative/teleport tiles in late biomes).

### Ability Design Notes
- Encourage synergies across classes (ignite oil, shatter frozen targets).
- Keep numbers readable; prefer clear statuses over opaque math.

### AI Guidelines
- Prioritize focus-fire on Vulnerable targets.
- Use terrain: avoid hazards, seek cover/choke points.
- Scale behavior complexity by biome depth (new abilities unlocked for enemies).


