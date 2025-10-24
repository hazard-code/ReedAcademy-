# ReedAcademy 🎷

A blockchain-based professional woodwind training platform built on Stacks that enables musicians to pursue certifications, complete skill assessments, and earn rewards for their musical development.

## Overview

ReedAcademy creates a decentralized educational ecosystem for reed instrument players (woodwinds like clarinet, saxophone, oboe, bassoon) where scholars can take professional certifications, demonstrate their skills through rigorous assessments, and earn Adagio Tokens (RAT) for their achievements. The platform combines professional certification, skill evaluation, and a reward system to incentivize continuous learning and mastery.

## Features

### 🎯 Core Functionality

- **Professional Certifications**: Create and offer structured certification programs
- **Skill Assessments**: Take comprehensive assessments across multiple skill dimensions
- **Certification Evaluations**: Review and rate certification programs
- **Scholar Profiles**: Build your academic profile with proficiency levels and achievements
- **Mastery System**: Unlock advanced achievements for dedication and excellence
- **Token Rewards**: Earn RAT tokens for assessments, certifications, and mastery

### 💰 Token Economics

**Token Details:**
- Name: ReedAcademy Adagio Token
- Symbol: RAT
- Decimals: 6
- Max Supply: 45,000 RAT

**Reward Structure:**
- Pass Skill Assessment: 2.9 RAT
- Fail Skill Assessment: 0.29 RAT (10% consolation)
- Create Certification: 7.4 RAT
- Claim Mastery Achievement: 16.5 RAT

## Smart Contract Functions

### Public Functions

#### `create-certification`
Create a new professional certification program.

```clarity
(create-certification 
  (certification-name (string-ascii 12))
  (skill-domain (string-ascii 11))
  (difficulty-tier (string-ascii 8))
  (duration uint)
  (passing-score uint)
  (max-candidates uint))
```

**Parameters:**
- `certification-name`: Name of the certification (max 12 characters)
- `skill-domain`: Domain of skill (e.g., "technique", "theory", "performance", "pedagogy", "composition")
- `difficulty-tier`: Difficulty level ("basic", "standard", "advanced", "expert")
- `duration`: Expected duration in minutes
- `passing-score`: Minimum average score required to pass (1-5)
- `max-candidates`: Maximum number of candidates allowed

**Returns:** Certification ID

**Rewards:** 7.4 RAT tokens

---

#### `take-assessment`
Complete a skill assessment for a certification.

```clarity
(take-assessment
  (certification-id uint)
  (skill-area (string-ascii 11))
  (assessment-time uint)
  (practical-score uint)
  (theoretical-knowledge uint)
  (application-ability uint)
  (assessment-notes (string-ascii 14)))
```

**Parameters:**
- `certification-id`: ID of the certification being assessed
- `skill-area`: Specific skill area being tested
- `assessment-time`: Time spent on assessment (minutes)
- `practical-score`: Practical performance score (1-5)
- `theoretical-knowledge`: Theory knowledge score (1-5)
- `application-ability`: Application skills score (1-5)
- `assessment-notes`: Brief notes about the assessment

**Passing Criteria:**
- Average of the three scores must meet or exceed the certification's passing score
- Formula: (practical + theoretical + application) / 3 ≥ passing-score

**Returns:** Assessment ID

**Rewards:** 
- Pass: 2.9 RAT tokens
- Fail: 0.29 RAT tokens (consolation reward)

---

#### `write-evaluation`
Write an evaluation/review for a certification program.

```clarity
(write-evaluation
  (certification-id uint)
  (rating uint)
  (evaluation-text (string-ascii 14))
  (instruction-effectiveness (string-ascii 6)))
```

**Parameters:**
- `certification-id`: ID of the certification to evaluate
- `rating`: Overall rating (1-10)
- `evaluation-text`: Written evaluation (max 14 characters)
- `instruction-effectiveness`: Teaching quality ("poor", "fair", "good", "strong", "superb")

**Restrictions:**
- Can only evaluate each certification once

---

#### `endorse-evaluation`
Endorse another user's evaluation of a certification.

```clarity
(endorse-evaluation
  (certification-id uint)
  (evaluator principal))
```

**Parameters:**
- `certification-id`: ID of the certification
- `evaluator`: Principal of the user who wrote the evaluation

**Restrictions:**
- Cannot endorse your own evaluations

---

#### `update-proficiency-level`
Update your proficiency level designation.

```clarity
(update-proficiency-level (new-proficiency-level (string-ascii 12)))
```

**Supported Levels:**
- novice
- developing
- proficient
- advanced
- expert

---

#### `claim-mastery`
Claim advanced mastery achievements for exceptional dedication.

```clarity
(claim-mastery (mastery (string-ascii 14)))
```

**Available Masteries:**
- `"skill-expert"`: Complete 40 assessments
- `"cert-master"`: Earn 8 certifications

**Rewards:** 16.5 RAT tokens per mastery

---

#### `update-academic-name`
Set or update your academic name/display name.

```clarity
(update-academic-name (new-academic-name (string-ascii 17)))
```

### Read-Only Functions

#### `get-scholar-profile`
Get a scholar's profile information.

```clarity
(get-scholar-profile (scholar principal))
```

**Returns:**
- academic-name
- proficiency-level
- assessments-taken
- certifications-earned
- total-study-time (in hours)
- skill-mastery (1-5 scale)
- enrollment-date

---

#### `get-professional-certification`
Get certification details by ID.

```clarity
(get-professional-certification (certification-id uint))
```

**Returns:**
- certification-name
- skill-domain
- difficulty-tier
- duration
- passing-score
- max-candidates
- instructor
- assessment-count
- mastery-rating (average)

---

#### `get-skill-assessment`
Get assessment details by ID.

```clarity
(get-skill-assessment (assessment-id uint))
```

**Returns:**
- certification-id
- scholar
- skill-area
- assessment-time
- practical-score
- theoretical-knowledge
- application-ability
- assessment-notes
- assessment-date
- passed (boolean)

---

#### `get-certification-evaluation`
Get a specific evaluation for a certification.

```clarity
(get-certification-evaluation (certification-id uint) (evaluator principal))
```

**Returns:**
- rating
- evaluation-text
- instruction-effectiveness
- evaluation-date
- endorsement-votes

---

#### `get-mastery`
Check if a scholar has achieved a specific mastery.

```clarity
(get-mastery (scholar principal) (mastery (string-ascii 14)))
```

---

#### Token Functions
- `get-name`: Returns token name
- `get-symbol`: Returns token symbol
- `get-decimals`: Returns token decimals
- `get-balance`: Returns balance for a user

## Scholar Progression System

### Proficiency Levels
Progress through five distinct levels:
1. **Novice**: Just starting the musical journey
2. **Developing**: Building foundational skills
3. **Proficient**: Solid core competencies
4. **Advanced**: High-level technical abilities
5. **Expert**: Masterful command of the instrument

### Skill Mastery Score
Your skill mastery increases based on:
- Practical scores from assessments (score/30 per assessment)
- Cumulative growth over time
- Ranges from 1-5 scale

### Profile Statistics
Each scholar profile tracks:
- Total assessments taken
- Total certifications earned
- Total study time (converted to hours)
- Current skill mastery level
- Enrollment date

## Assessment Scoring System

### Three-Dimensional Evaluation
Each assessment measures:
1. **Practical Score** (1-5): Physical technique and performance
2. **Theoretical Knowledge** (1-5): Understanding of music theory
3. **Application Ability** (1-5): Real-world application of skills

### Pass/Fail Determination
- Average score = (Practical + Theoretical + Application) / 3
- Must meet or exceed the certification's passing score
- Failed attempts still receive 10% token reward (0.29 RAT)

## Certification Program Structure

### Skill Domains
- **technique**: Physical playing skills
- **theory**: Music theory and analysis
- **performance**: Stage presence and delivery
- **pedagogy**: Teaching methodologies
- **composition**: Creating original music

### Difficulty Tiers
- **basic**: Foundational level
- **standard**: Intermediate requirements
- **advanced**: High-level challenges
- **expert**: Master-level demands

## Usage Examples

### Creating a Certification

```clarity
(contract-call? .reed-academy create-certification
  "Reed Mastery"
  "technique"
  "advanced"
  u120
  u4
  u50)
```

### Taking an Assessment

```clarity
(contract-call? .reed-academy take-assessment
  u1
  "embouchure"
  u90
  u5
  u4
  u5
  "Excellent!")
```

### Writing an Evaluation

```clarity
(contract-call? .reed-academy write-evaluation
  u1
  u9
  "Outstanding!"
  "superb")
```

### Endorsing an Evaluation

```clarity
(contract-call? .reed-academy endorse-evaluation
  u1
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Claiming Mastery

```clarity
(contract-call? .reed-academy claim-mastery "skill-expert")
```

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | err-owner-only | Operation restricted to contract owner |
| u101 | err-not-found | Resource not found |
| u102 | err-already-exists | Resource already exists |
| u103 | err-unauthorized | Unauthorized action |
| u104 | err-invalid-input | Invalid input parameters |

## Security Considerations

1. **Evaluation Protection**: Users can only evaluate each certification once
2. **Self-Endorsement Prevention**: Cannot endorse your own evaluations
3. **Score Validation**: All scores validated within 1-5 or 1-10 ranges
4. **Mastery Claims**: One-time claims with strict requirements
5. **Token Supply Cap**: Maximum supply enforced at 45,000 RAT
6. **Input Validation**: All inputs validated for proper ranges and lengths

## Token Economics Analysis

**Maximum Token Distribution:**
- Assessments (pass): Unlimited × 2.9 RAT = Primary distribution
- Assessments (fail): Unlimited × 0.29 RAT = Secondary distribution
- Certifications: Unlimited × 7.4 RAT = Instructor rewards
- Masteries: 2 masteries × 16.5 RAT = 33 RAT per scholar max
- **Total Supply Cap**: 45,000 RAT (45,000,000,000 micro-tokens)

The reward structure incentivizes both assessment completion (learning) and certification creation (teaching), while providing consolation rewards for failed attempts to encourage persistence.

## Development

### Prerequisites
- Stacks blockchain node
- Clarinet CLI for testing

### Testing
Run the test suite with:
```bash
clarinet test
```

### Deployment
Deploy to testnet/mainnet using:
```bash
clarinet deploy
```

## Roadmap

### Phase 2
- [ ] Video assessment uploads
- [ ] Peer review system
- [ ] Practice log tracking
- [ ] Instrument-specific tracks (clarinet, saxophone, etc.)

### Phase 3
- [ ] Live virtual masterclasses
- [ ] Ensemble formation tools
- [ ] Performance scheduling
- [ ] Sheet music library integration

### Phase 4
- [ ] NFT certificates for completed programs
- [ ] Scholarship funding mechanisms
- [ ] Professional networking features
- [ ] Competition hosting platform

## Use Cases

### For Students
- Structured learning paths
- Verified skill credentials
- Progress tracking
- Earn while learning

### For Instructors
- Create certification programs
- Build reputation through evaluations
- Earn tokens for teaching
- Track student progress

### For Institutions
- Standardized assessment metrics
- Immutable credential records
- Quality control through reviews
- Performance analytics

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Support

For questions or support, please open an issue in the repository.

---

**Built with 🎵 for the woodwind community on Stacks blockchain**
