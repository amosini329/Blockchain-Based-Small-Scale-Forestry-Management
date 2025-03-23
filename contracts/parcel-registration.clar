;; Parcel Registration Contract
;; Records details of managed woodland areas

;; Data Variables
(define-data-var parcel-counter uint u0)

;; Data Maps
(define-map parcels
  { parcel-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    location: (string-utf8 100),
    area: uint,
    tree-species: (list 10 (string-utf8 50)),
    registration-date: uint
  }
)

(define-map owner-parcels
  { owner: principal }
  { parcel-ids: (list 100 uint) }
)

;; Register a new woodland parcel
(define-public (register-parcel
    (name (string-utf8 100))
    (location (string-utf8 100))
    (area uint)
    (tree-species (list 10 (string-utf8 50))))
  (let ((parcel-id (var-get parcel-counter)))
    (begin
      ;; Store the parcel information
      (map-set parcels
        { parcel-id: parcel-id }
        {
          owner: tx-sender,
          name: name,
          location: location,
          area: area,
          tree-species: tree-species,
          registration-date: block-height
        }
      )

      ;; Update owner-to-parcel mapping
      (let ((owner-list (default-to { parcel-ids: (list) } (map-get? owner-parcels { owner: tx-sender }))))
        (map-set owner-parcels
          { owner: tx-sender }
          { parcel-ids: (unwrap-panic (as-max-len? (append (get parcel-ids owner-list) parcel-id) u100)) }
        )
      )

      ;; Increment counter and return parcel ID
      (var-set parcel-counter (+ parcel-id u1))
      (ok parcel-id)
    )
  )
)

;; Get parcel details by ID
(define-read-only (get-parcel (parcel-id uint))
  (map-get? parcels { parcel-id: parcel-id })
)

;; Get all parcels owned by a user
(define-read-only (get-owner-parcels (owner principal))
  (default-to { parcel-ids: (list) } (map-get? owner-parcels { owner: owner }))
)

;; Get the total number of registered parcels
(define-read-only (get-parcel-count)
  (var-get parcel-counter)
)
