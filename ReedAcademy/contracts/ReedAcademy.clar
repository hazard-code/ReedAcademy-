;; ReedAcademy - Professional Woodwind Training Platform
;; A blockchain-based platform for reed instrument education, skill assessment,
;; and professional development certification

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "ReedAcademy Adagio Token")
(define-constant token-symbol "RAT")
(define-constant token-decimals u6)
(define-constant token-max-supply u45000000000) ;; 45k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-assessment u2900000) ;; 2.9 RAT
(define-constant reward-certification u7400000) ;; 7.4 RAT
(define-constant reward-mastery u16500000) ;; 16.5 RAT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-certification-id uint u1)
(define-data-var next-assessment-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Scholar profiles
(define-map scholar-profiles
  principal
  {
    academic-name: (string-ascii 17),
    proficiency-level: (string-ascii 12), ;; "novice", "developing", "proficient", "advanced", "expert"
    assessments-taken: uint,
    certifications-earned: uint,
    total-study-time: uint,
    skill-mastery: uint, ;; 1-5
    enrollment-date: uint
  }
)

;; Professional certifications
(define-map professional-certifications
  uint
  {
    certification-name: (string-ascii 12),
    skill-domain: (string-ascii 11), ;; "technique", "theory", "performance", "pedagogy", "composition"
    difficulty-tier: (string-ascii 8), ;; "basic", "standard", "advanced", "expert"
    duration: uint, ;; minutes
    passing-score: uint, ;; minimum score required
    max-candidates: uint,
    instructor: principal,
    assessment-count: uint,
    mastery-rating: uint ;; average mastery
  }
)

;; Skill assessments
(define-map skill-assessments
  uint
  {
    certification-id: uint,
    scholar: principal,
    skill-area: (string-ascii 11),
    assessment-time: uint, ;; minutes
    practical-score: uint, ;; 1-5
    theoretical-knowledge: uint, ;; 1-5
    application-ability: uint, ;; 1-5
    assessment-notes: (string-ascii 14),
    assessment-date: uint,
    passed: bool
  }
)

;; Certification evaluations
(define-map certification-evaluations
  { certification-id: uint, evaluator: principal }
  {
    rating: uint, ;; 1-10
    evaluation-text: (string-ascii 14),
    instruction-effectiveness: (string-ascii 6), ;; "poor", "fair", "good", "strong", "superb"
    evaluation-date: uint,
    endorsement-votes: uint
  }
)

;; Academic masteries
(define-map academic-masteries
  { scholar: principal, mastery: (string-ascii 14) }
  {
    mastery-date: uint,
    assessment-total: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (scholar principal))
  (match (map-get? scholar-profiles scholar)
    profile profile
    {
      academic-name: "",
      proficiency-level: "novice",
      assessments-taken: u0,
      certifications-earned: u0,
      total-study-time: u0,
      skill-mastery: u1,
      enrollment-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Create professional certification
(define-public (create-certification (certification-name (string-ascii 12)) (skill-domain (string-ascii 11)) (difficulty-tier (string-ascii 8)) (duration uint) (passing-score uint) (max-candidates uint))
  (let (
    (certification-id (var-get next-certification-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len certification-name) u0) err-invalid-input)
    (asserts! (> duration u0) err-invalid-input)
    (asserts! (and (>= passing-score u1) (<= passing-score u5)) err-invalid-input)
    (asserts! (> max-candidates u0) err-invalid-input)
    
    (map-set professional-certifications certification-id {
      certification-name: certification-name,
      skill-domain: skill-domain,
      difficulty-tier: difficulty-tier,
      duration: duration,
      passing-score: passing-score,
      max-candidates: max-candidates,
      instructor: tx-sender,
      assessment-count: u0,
      mastery-rating: u0
    })
    
    ;; Update profile
    (map-set scholar-profiles tx-sender
      (merge profile {certifications-earned: (+ (get certifications-earned profile) u1)})
    )
    
    ;; Award certification creation tokens
    (try! (mint-tokens tx-sender reward-certification))
    
    (var-set next-certification-id (+ certification-id u1))
    (print {action: "certification-created", certification-id: certification-id, instructor: tx-sender})
    (ok certification-id)
  )
)

;; Take skill assessment
(define-public (take-assessment (certification-id uint) (skill-area (string-ascii 11)) (assessment-time uint) (practical-score uint) (theoretical-knowledge uint) (application-ability uint) (assessment-notes (string-ascii 14)))
  (let (
    (assessment-id (var-get next-assessment-id))
    (certification (unwrap! (map-get? professional-certifications certification-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
    (average-score (/ (+ practical-score theoretical-knowledge application-ability) u3))
    (passed (>= average-score (get passing-score certification)))
  )
    (asserts! (> assessment-time u0) err-invalid-input)
    (asserts! (and (>= practical-score u1) (<= practical-score u5)) err-invalid-input)
    (asserts! (and (>= theoretical-knowledge u1) (<= theoretical-knowledge u5)) err-invalid-input)
    (asserts! (and (>= application-ability u1) (<= application-ability u5)) err-invalid-input)
    
    (map-set skill-assessments assessment-id {
      certification-id: certification-id,
      scholar: tx-sender,
      skill-area: skill-area,
      assessment-time: assessment-time,
      practical-score: practical-score,
      theoretical-knowledge: theoretical-knowledge,
      application-ability: application-ability,
      assessment-notes: assessment-notes,
      assessment-date: stacks-block-height,
      passed: passed
    })
    
    ;; Update certification stats if passed
    (if passed
      (let (
        (new-assessment-count (+ (get assessment-count certification) u1))
        (current-mastery (* (get mastery-rating certification) (get assessment-count certification)))
        (mastery-value average-score)
        (new-mastery-rating (/ (+ current-mastery mastery-value) new-assessment-count))
      )
        (map-set professional-certifications certification-id
          (merge certification {
            assessment-count: new-assessment-count,
            mastery-rating: new-mastery-rating
          })
        )
        true
      )
      true
    )
    
    ;; Update profile
    (if passed
      (begin
        (map-set scholar-profiles tx-sender
          (merge profile {
            assessments-taken: (+ (get assessments-taken profile) u1),
            total-study-time: (+ (get total-study-time profile) (/ assessment-time u60)),
            skill-mastery: (+ (get skill-mastery profile) (/ practical-score u30))
          })
        )
        (try! (mint-tokens tx-sender reward-assessment))
        true
      )
      (begin
        (try! (mint-tokens tx-sender (/ reward-assessment u10)))
        true
      )
    )
    
    (var-set next-assessment-id (+ assessment-id u1))
    (print {action: "assessment-taken", assessment-id: assessment-id, certification-id: certification-id, passed: passed})
    (ok assessment-id)
  )
)

;; Write certification evaluation
(define-public (write-evaluation (certification-id uint) (rating uint) (evaluation-text (string-ascii 14)) (instruction-effectiveness (string-ascii 6)))
  (let (
    (certification (unwrap! (map-get? professional-certifications certification-id) err-not-found))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len evaluation-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? certification-evaluations {certification-id: certification-id, evaluator: tx-sender})) err-already-exists)
    
    (map-set certification-evaluations {certification-id: certification-id, evaluator: tx-sender} {
      rating: rating,
      evaluation-text: evaluation-text,
      instruction-effectiveness: instruction-effectiveness,
      evaluation-date: stacks-block-height,
      endorsement-votes: u0
    })
    
    (print {action: "evaluation-written", certification-id: certification-id, evaluator: tx-sender})
    (ok true)
  )
)

;; Endorse evaluation
(define-public (endorse-evaluation (certification-id uint) (evaluator principal))
  (let (
    (evaluation (unwrap! (map-get? certification-evaluations {certification-id: certification-id, evaluator: evaluator}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender evaluator)) err-unauthorized)
    
    (map-set certification-evaluations {certification-id: certification-id, evaluator: evaluator}
      (merge evaluation {endorsement-votes: (+ (get endorsement-votes evaluation) u1)})
    )
    
    (print {action: "evaluation-endorsed", certification-id: certification-id, evaluator: evaluator})
    (ok true)
  )
)

;; Update proficiency level
(define-public (update-proficiency-level (new-proficiency-level (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-proficiency-level) u0) err-invalid-input)
    
    (map-set scholar-profiles tx-sender (merge profile {proficiency-level: new-proficiency-level}))
    
    (print {action: "proficiency-updated", scholar: tx-sender, level: new-proficiency-level})
    (ok true)
  )
)

;; Claim academic mastery
(define-public (claim-mastery (mastery (string-ascii 14)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? academic-masteries {scholar: tx-sender, mastery: mastery})) err-already-exists)
    
    ;; Check mastery requirements
    (let (
      (mastery-achieved
        (if (is-eq mastery "skill-expert") (>= (get assessments-taken profile) u40)
        (if (is-eq mastery "cert-master") (>= (get certifications-earned profile) u8)
        false)))
    )
      (asserts! mastery-achieved err-unauthorized)
      
      ;; Record mastery
      (map-set academic-masteries {scholar: tx-sender, mastery: mastery} {
        mastery-date: stacks-block-height,
        assessment-total: (get assessments-taken profile)
      })
      
      ;; Award mastery tokens
      (try! (mint-tokens tx-sender reward-mastery))
      
      (print {action: "mastery-claimed", scholar: tx-sender, mastery: mastery})
      (ok true)
    )
  )
)

;; Update academic name
(define-public (update-academic-name (new-academic-name (string-ascii 17)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-academic-name) u0) err-invalid-input)
    (map-set scholar-profiles tx-sender (merge profile {academic-name: new-academic-name}))
    (print {action: "academic-name-updated", scholar: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-scholar-profile (scholar principal))
  (map-get? scholar-profiles scholar)
)

(define-read-only (get-professional-certification (certification-id uint))
  (map-get? professional-certifications certification-id)
)

(define-read-only (get-skill-assessment (assessment-id uint))
  (map-get? skill-assessments assessment-id)
)

(define-read-only (get-certification-evaluation (certification-id uint) (evaluator principal))
  (map-get? certification-evaluations {certification-id: certification-id, evaluator: evaluator})
)

(define-read-only (get-mastery (scholar principal) (mastery (string-ascii 14)))
  (map-get? academic-masteries {scholar: scholar, mastery: mastery})
)