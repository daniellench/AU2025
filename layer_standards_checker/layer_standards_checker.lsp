;; Enhanced Layer Standards Checker for Batch Processing
;; Optimized for AcCoreConsole.exe with detailed logging

(defun c:LayerStandardsCheck (/ layer-standards current-layers layer-data layer-name 
                               standard-props current-props changes-made error-count
                               log-file dwg-name start-time)
  
  ;; Get current drawing name for logging
  (setq dwg-name (getvar "DWGNAME"))
  (setq start-time (getvar "CDATE"))
  
  ;; Initialize log file path (same directory as drawing)
  (setq log-file (strcat (getvar "DWGPREFIX") "LayerStandardsLog.txt"))
  
  ;; Define comprehensive layer standards
  (setq layer-standards
    '(
      ("0" (7 "CONTINUOUS" -3 0))  ; White, Continuous, Default lineweight, No transparency
      ("A-BLDG" (7 "CONTINUOUS" -3 0))
      ("A-BLDG-FPRT" (5 "CONTINUOUS" -3 0))  ; Blue
      ("A-BLDG-SITE" (6 "CONTINUOUS" -3 0))  ; Magenta
      ("A-BLDG-UTIL" (7 "CONTINUOUS" -3 0))
      ("A-PROP-LINE" (7 "CONTINUOUS" -3 0))
      ("C-ANNO" (7 "CONTINUOUS" -3 0))
      ("C-ANNO-MATC" (7 "DASHED" -3 0))
      ("C-ANNO-MATC-PATT" (7 "CONTINUOUS" -3 0))
      ("C-ANNO-MATC-TEXT" (150 "CONTINUOUS" -3 0))
      ("C-ANNO-TABL" (1 "CONTINUOUS" -3 0))  ; Red
      ("C-ANNO-TABL-PATT" (7 "CONTINUOUS" -3 0))
      ("C-ANNO-TABL-TEXT" (150 "CONTINUOUS" -3 0))
      ("C-ANNO-TABL-TITL" (150 "CONTINUOUS" -3 0))
      ("C-ANNO-TABL-TTBL" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-ANNO-VFRM" (150 "CONTINUOUS" -3 0))
      ("C-ANNO-VFRM-TEXT" (11 "CONTINUOUS" -3 0))
      ("C-BRDG-ABUTMENT" (4 "CONTINUOUS" -3 0))  ; Cyan
      ("C-BRDG-DECK" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-BRDG-FOUNDATION" (2 "CONTINUOUS" -3 0))  ; Yellow
      ("C-BRDG-GENERICOBJECT" (6 "CONTINUOUS" -3 0))  ; Magenta
      ("C-BRDG-GIRDER" (3 "CONTINUOUS" -3 0))  ; Green
      ("C-BRDG-PIER" (1 "CONTINUOUS" -3 0))  ; Red
      ("C-ESMT-ROAD" (23 "CONTINUOUS" -3 0))
      ("C-HYDR-CTCH" (6 "CONTINUOUS" -3 0))  ; Magenta
      ("C-HYDR-CTCH-BNDY" (6 "CONTINUOUS" -3 0))
      ("C-HYDR-CTCH-DSPT" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-HYDR-CTCH-FPTH" (4 "CONTINUOUS" -3 0))  ; Cyan
      ("C-HYDR-CTCH-FPTH-TEXT" (7 "CONTINUOUS" -3 0))
      ("C-HYDR-CTCH-FSPT" (30 "CONTINUOUS" -3 0))
      ("C-HYDR-CTCH-HDPT" (2 "CONTINUOUS" -3 0))  ; Yellow
      ("C-HYDR-CTCH-TEXT" (7 "CONTINUOUS" -3 0))
      ("C-HYDR-TEXT" (7 "CONTINUOUS" -3 0))
      ("C-PROP-BNDY" (150 "CONTINUOUS" -3 0))
      ("C-PROP-BRNG" (92 "CONTINUOUS" -3 0))
      ("C-PROP-LINE" (230 "CONTINUOUS" -3 0))
      ("C-PROP-LINE-TEXT" (150 "CONTINUOUS" -3 0))
      ("C-PROP-LOTS" (6 "CONTINUOUS" -3 0))  ; Magenta
      ("C-PROP-PATT" (150 "CONTINUOUS" -3 0))
      ("C-PROP-RSRV" (94 "CONTINUOUS" -3 0))
      ("C-PROP-TEXT" (92 "CONTINUOUS" -3 0))
      ("C-ROAD-CNTR" (1 "CENTER2" -3 0))  ; Red, Center2
      ("C-ROAD-CNTR-N" (92 "CONTINUOUS" -3 0))
      ("C-ROAD-CORR" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-ROAD-CORR-BNDY" (1 "CENTER2" -3 0))  ; Red, Center2
      ("C-ROAD-PROF" (1 "DASHED" -3 0))  ; Red, Dashed
      ("C-SSWR-CNTR" (200 "CONTINUOUS" -3 0))
      ("C-SSWR-PIPE" (200 "CONTINUOUS" -3 0))
      ("C-STRM-CNTR" (170 "CENTER2" -3 0))
      ("C-STRM-PIPE" (170 "CONTINUOUS" -3 0))
      ("C-TINN" (4 "CONTINUOUS" -3 0))  ; Cyan
      ("C-TOPO-MAJR" (9 "CONTINUOUS" -3 0))
      ("C-TOPO-MINR" (8 "CONTINUOUS" -3 0))
      ("C-WATR-CNTR" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-WATR-PIPE" (5 "CONTINUOUS" -3 0))  ; Blue
      ("C-WATR-TEXT" (7 "DASHED" -3 0))  ; White, Dashed
      ("V-ROAD-CNTR" (1 "CENTER" -3 0))  ; Red, Center
      ("V-SITE-FNCE" (150 "FENCELINE2" -3 0))
      ("Defpoints" (7 "CONTINUOUS" -3 0))
    )
  )
  
  ;; Initialize counters
  (setq changes-made 0
        error-count 0)
  
  ;; Function to write to log file
  (defun write-log (message / file)
    (if (setq file (open log-file "a"))
      (progn
        (write-line message file)
        (close file)
      )
    )
    (princ (strcat "\n" message))
  )
  
  ;; Function to ensure linetype is loaded
  (defun ensure-linetype-loaded (linetype-name / )
    (if (not (tblsearch "LTYPE" linetype-name))
      (progn
        (command "._-LINETYPE" "_L" linetype-name "ACAD.LIN" "")
        (write-log (strcat "  Loaded linetype: " linetype-name))
      )
    )
  )
  
  ;; Function to check and fix a single layer
  (defun check-and-fix-layer (layer-name standard-props / layer-obj current-color 
                               current-linetype std-color std-linetype changes-this-layer)
    (setq changes-this-layer 0)
    (setq layer-obj (tblsearch "LAYER" layer-name))
    
    (if layer-obj
      (progn
        ;; Get current properties
        (setq current-color (cdr (assoc 62 layer-obj))
              current-linetype (cdr (assoc 6 layer-obj)))
        
        ;; Handle negative colors (layer is off)
        (if (and current-color (< current-color 0))
          (setq current-color (abs current-color))
        )
        
        ;; Get standard values
        (setq std-color (nth 0 standard-props)
              std-linetype (nth 1 standard-props))
        
        ;; Ensure required linetype is loaded
        (ensure-linetype-loaded std-linetype)
        
        ;; Check and fix color
        (if (or (not current-color) (/= current-color std-color))
          (progn
            (command "._-LAYER" "_C" std-color layer-name "")
            (write-log (strcat "    Fixed color: " (itoa current-color) " -> " (itoa std-color)))
            (setq changes-this-layer (1+ changes-this-layer))
          )
        )
        
        ;; Check and fix linetype
        (if (or (not current-linetype) 
                (/= (strcase current-linetype) (strcase std-linetype)))
          (progn
            (command "._-LAYER" "_L" std-linetype layer-name "")
            (write-log (strcat "    Fixed linetype: " 
                              (if current-linetype current-linetype "NONE") 
                              " -> " std-linetype))
            (setq changes-this-layer (1+ changes-this-layer))
          )
        )
        
        ;; Return number of changes for this layer
        changes-this-layer
      )
      (progn
        (write-log (strcat "  WARNING: Layer not found - " layer-name))
        (setq error-count (1+ error-count))
        0
      )
    )
  )
  
  ;; Start logging
  (write-log "")
  (write-log "========================================")
  (write-log (strcat "Layer Standards Check: " dwg-name))
  (write-log (strcat "Started: " (rtos start-time 2 6)))
  (write-log "========================================")
  
  ;; Process each layer in standards
  (foreach layer-standard layer-standards
    (setq layer-name (nth 0 layer-standard)
          standard-props (nth 1 layer-standard))
    
    (write-log (strcat "Checking layer: " layer-name))
    (setq layer-changes (check-and-fix-layer layer-name standard-props))
    (setq changes-made (+ changes-made layer-changes))
    
    (if (= layer-changes 0)
      (write-log "  OK - No changes needed")
    )
  )
  
  ;; Final summary
  (write-log "========================================")
  (write-log (strcat "SUMMARY - " dwg-name))
  (write-log (strcat "Total changes made: " (itoa changes-made)))
  (write-log (strcat "Layers not found: " (itoa error-count)))
  (write-log (strcat "Completed: " (rtos (getvar "CDATE") 2 6)))
  (write-log "========================================")
  
  ;; Regenerate drawing if changes were made
  (if (> changes-made 0)
    (progn
      (command "._REGEN")
      (write-log "Drawing regenerated")
    )
  )
  
  ;; Console output for batch processing
  (princ (strcat "\nLayer Standards Check Complete: " dwg-name))
  (princ (strcat "\nChanges: " (itoa changes-made) " | Errors: " (itoa error-count)))
  
  (princ)
)

;; Batch processing helper function
(defun c:LayerStandardsBatch (/ file-list)
  (write-log "Starting batch layer standards processing...")
  (c:LayerStandardsCheck)
  (princ)
)

;; Load message (only show in interactive mode)
(if (= (getvar "CMDACTIVE") 0)
  (progn
    (princ "\nEnhanced Layer Standards Checker Loaded!")
    (princ "\nOptimized for batch processing with AcCoreConsole.exe")
    (princ "\nCommands: LAYERSTANDARDSCHECK, LAYERSTANDARDSBATCH")
  )
)

(princ)