# 🎮 AARPG Tutorial - Interactive Game Walkthrough

## Starting the Game

### Title Screen
When you first launch the game, you'll see:
- **AARPG Tutorial** title with Michael Games branding
- **"New Game"** button (starts fresh)
- **"Continue"** button (loads saved progress, disabled if no save exists)
- Background music playing
- Focus effects on menu items

### Game Start Sequence
1. **Press "New Game"** → Scene transitions to Area01 Level 2
2. **Player spawns** at designated location
3. **Player becomes visible** and HUD appears
4. **Background music** changes to area theme
5. **Gameplay begins** with full control

---

## Playing Area01 Level 2 (Starting Area)

### 🏁 Player Spawn Point
- Start with **6 HP** (health hearts)
- **Level 1** with 0 XP
- **10 Arrows** in inventory
- **10 Bombs** available
- **6 Abilities** unlocked: Sword, Bow, Bombs, Boomerang, Grapple, Dash

### 🎯 Key NPCs to Meet

#### NERO (Quest Giver) - Position: (329, 172)
**Dialogue Sequence:**
1. **"Hi, Hero is that you?"** → Acknowledge the player
2. **Player Response:** "[wave]Heck yeah it's me![/wave]" 
3. **Nero's Reply:** "Nice bro! Happy to have a hero!"

**Quest Trigger:**
- After dialogue, **QuestActivatedSwitch** activates
- **"Recover Lost Magical Flute"** quest begins
- **Step 1:** Find the Cave Entrance (unlock Dungeon01 access)

#### Other NPCs in the Area
- **NPC_01:** Wanders around, provides tips
- **NPC_02:** Different interaction pattern
- **Shopkeeper:** Available for trading

---

## 🏪 Available Systems

### Shop Area
- **Location:** Designated shop area in Level 2
- **Currency:** Gems (starting amount varies)
- **Items for Sale:** Potions, equipment, ammunition
- **Currency Exchange:** Buy/sell items and equipment

### Treasure Chests
- **Hidden throughout areas**
- **Contains:** Random items, gems, equipment
- **Interaction:** Press C or Gamepad B to open
- **Contents:** Based on area and difficulty

---

## ⚔️ Combat Testing

### Try Each Ability:

#### 1. Sword (Melee Combat)
- **Input:** X key / Gamepad A / Left mouse
- **Effect:** 4-directional attack in facing direction
- **Animation:** AttackSprite01 with spin effects
- **Damage:** Based on attack stat (starts at 1)

#### 2. Bow & Arrows (Ranged)
- **Input:** Press ability button → Bow mode
- **Input:** X key to fire arrows
- **Effect:** Fires arrows in cardinal directions
- **Ammunition:** Consumes arrows (starts with 10)
- **Sound Effect:** bow_fire.wav

#### 3. Bombs (Explosives)
- **Input:** Press ability button → Bomb mode
- **Input:** X key to throw bomb
- **Effect:** Explodes after timer, area damage
- **Uses:** Combat, puzzle solving
- **Starting Count:** 10 bombs

#### 4. Boomerang (Returns)
- **Input:** Press ability button → Boomerang mode
- **Input:** X key to throw
- **Effect:** Travels in arc, returns to player
- **Advantages:** Hits multiple targets, returns to hand
- **Visual:** boomerang.png animation

#### 5. Grapple (Traversal)
- **Input:** Press ability button → Grapple mode
- **Input:** X key to fire grapple
- **Effect:** Attach to grapple points, swing across gaps
- **Locations:** Grapple posts scattered throughout areas
- **Visual:** grapple.png rope animation

#### 6. Dash (Mobility)
- **Input:** Shift key / Gamepad Right Bumper
- **Effect:** Quick burst movement in input direction
- **Uses:** Evade attacks, cross gaps quickly
- **Visual:** Speed effect with motion blur

---

## 🗺️ Exploring the World

### Area01 Level 2 Features
- **Grass terrain** with collision detection
- **Plants and props** for decoration
- **Interactive elements** (pushable objects)
- **Music:** example_music_01.ogg playing in background
- **Transitions:** Doorways to other areas

### Available Transitions
- **Level 1:** Tutorial area with basic mechanics
- **Level 3:** More complex puzzles and enemies
- **Level 4:** Cutscene area with story progression
- **Dungeon01:** Underground area (unlocked by quest)

---

## 💎 Items & Equipment

### Collectible Items
- **Gems:** Currency for shops (sparkling animation)
- **Potions:** Restore health (red flask icon)
- **Equipment Upgrades:** 
  - Ninja Suit (changes player sprite)
  - Various weapons (affect combat stats)

### Item Pickups
- **Visual:** Item pickup animation
- **Sound:** Collection sound effect
- **HUD Update:** Arrow/bomb counts update
- **Auto-collect:** Walk over items to collect

---

## 📊 Player Progression

### Stats System
- **HP:** 6/6 starting health
- **Level:** 1 (progresses with XP)
- **Attack:** 1 (increases with levels/equipment)
- **Defense:** 1 (damage reduction)
- **XP:** Tracks progress toward next level

### Ability Progression
- **Starting:** All 6 abilities available
- **Upgrades:** Equipment can enhance abilities
- **Switching:** Press Z to cycle through abilities
- **Visual Feedback:** HUD shows current ability

---

## 🎯 Quest Progression

### "Recover Lost Magical Flute"
1. **Talk to Nero** ✅ (Complete)
2. **Find Cave Entrance** → Locate Dungeon01 access
3. **Enter Dungeon01** → Explore underground maze
4. **Find Magical Flute** → Hidden in dungeon treasure
5. **Return to Nero** → Turn in quest
6. **Receive Rewards** → 100 XP, 100 Gems, 5 Potions

### Quest Mechanics
- **Progress Tracking:** HUD shows current objective
- **Auto-Save:** Quest progress saved automatically
- **Branch Points:** Some quests have multiple solutions
- **Rewards:** Immediate upon completion

---

## 🎵 Audio Experience

### Background Music
- **Title Screen:** Menu theme music
- **Area01:** Uplifting adventure theme
- **Combat:** Action music during battles
- **Shops:** Ambient shopping music

### Sound Effects
- **Menu Navigation:** Button focus/selection sounds
- **Combat:** Sword swings, arrow firing, explosions
- **Interaction:** Item pickup, chest opening, NPC voices
- **Environment:** Footsteps on different surfaces

---

## 🏆 Game Completion

### Success Criteria
- **Complete Main Quest:** Recover magical flute
- **Explore All Areas:** Visit Area01 levels 1-4 and Dungeon01
- **Maximize Character:** Level up, collect equipment
- **Experience All Systems:** Combat, shops, quests, dialogue

### Post-Quest Gameplay
- **Free Exploration:** Continue after quest completion
- **New Areas Unlock:** Additional content becomes available
- **Replay Value:** Try different approaches and abilities

---

## 💡 Pro Tips for First Playthrough

1. **Talk to Everyone:** NPCs provide valuable information
2. **Explore Thoroughly:** Hidden areas and treasure chests
3. **Save Frequently:** Use the save system (S key)
4. **Experiment:** Try all 6 abilities in different situations
5. **Manage Resources:** Don't waste arrows and bombs early
6. **Listen to Audio:** Sound cues indicate important events

---

**Ready to play? Open your project in Godot Engine and experience your complete AARPG Tutorial! 🎮**