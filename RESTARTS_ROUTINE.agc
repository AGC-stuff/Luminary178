### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RESTARTS_ROUTINE.agc
## Purpose:     A section of Luminary revision 178.
##              It is part of the reconstructed source code for the final
##              release of the flight software for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 14. The
##              code has been recreated from copies of Zerlina 56, Luminary
##              210, and Luminary 131, as well as many Luminary memos.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 178 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1292-1297
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Zerlina 56.
##              2019-09-15 MAS  Restored the definition of GOLOC.

## Page 1292
                BANK    01
                SETLOC  RESTART
                BANK

                EBANK=  PHSNAME1        # GOPROG MUST SWITCH TO THIS EBANK

                COUNT*  $$/RSROU
RESTARTS        CA      MPAC +5         # GET GROUP NUMBER -1
                DOUBLE                  # SAVE FOR INDEXING
                TS      TEMP2G

                CA      PHS2CADR        # SET UP EXIT IN CASE IT IS AN EVEN
                TS      TEMPSWCH        # TABLE PHASE

                CA      RTRNCADR        # TO SAVE TIME ASSUME IT WILL GET NEXT
                TS      GOLOC +2        # GROUP AFTER THIS

                CA      TEMPPHS
                MASK    OCT1400
                CCS     A               # IS IT A VARIABLE OR TABLE RESTART
                TCF     ITSAVAR         # IT:S A VARIABLE RESTART

GETPART2        CCS     TEMPPHS         # IS IT AN X.1 RESTART
                CCS     A
                TCF     ITSATBL         # NO, ITS A TABLE RESTART

                CA      PRIO14          # IT IS AN X.1 RESTART, THEREFORE START
                TC      FINDVAC         # THE DISPLAY RESTART JOB
                EBANK=  LST1
                2CADR   INITDSP

                TC      RTRNCADR        # FINISHED WITH THIS GROUP, GET NEXT ONE

ITSAVAR         MASK    OCT1400         # IS IT TYPE B ?
                CCS     A
                TCF     ITSLIKEB        # YES,IT IS TYPE B

                EXTEND                  # STORE THE JOB (OR TASK) 2CADR FOR EXIT
                NDX     TEMP2G
                DCA     PHSNAME1
                DXCH    GOLOC

                CA      TEMPPHS         # SEE IF THIS IS A JOB, TASK, OR A LONGCAL
                MASK    OCT7
                AD      MINUS2
                CCS     A
                TCF     ITSLNGCL        # ITS A LONGCALL

RTRNCADR        TC      SWRETURN        # CANT GET HERE

## Page 1293
                TCF     ITSAWAIT

                TCF     ITSAJOB         # ITS A JOB

ITSAWAIT        CA      WTLTCADR        # SET UP WAITLIST CALL
                TS      GOLOC -1

                NDX     TEMP2G          # DIRECTLY STORED
                CA      PHSPRDT1
TIMETEST        CCS     A               # IS IT AN IMMEDIATE RESTART
                INCR    A               # NO,
                TCF     FINDTIME        # FIND OUT WHEN IT SHOULD BEGIN

                TCF     ITSINDIR        # STORED INDIRECTLY

                TCF     IMEDIATE        # IT WANTS AN IMMEDIATE RESTART

# ***** THIS MUST BE IN FIXED FIXED *****

                BLOCK   02
                SETLOC  FFTAG2
                BANK

                COUNT*  $$/RSROU
ITSINDIR        LXCH    GOLOC +1        # GET THE CORRECT E BANK IN CASE THIS IS
                LXCH    BB              # SWITCHED ERRASIBLE

                NDX     A               # GET THE TIME INDIRECTLY
                CA      1

                LXCH    BB              # RESTORE THE BB AND GOLOC
                LXCH    GOLOC +1

                TCF     FINDTIME        # FIND OUT WHEN IT SHOULD BEGIN

# ***** YOU  MAY RETURN TO  SWITCHED FIXED *****

                BANK    01
                SETLOC  RESTART
                BANK

                COUNT*  $$/RSROU
FINDTIME        COM                     # MAKE NEGITIVE SINCE IT WILL BE SUBTRACTD
                TS      L               # AND SAVE
                NDX     TEMP2G
                CS      TBASE1
                EXTEND
                SU      TIME1
                CCS     A
                COM

## Page 1294
                AD      OCT37776
                AD      ONE
                AD      L
                CCS     A
                CA      ZERO
                TCF     +2
                TCF     +1
IMEDIATE        AD      ONE
                TC      GOLOC -1
ITSLIKEB        CA      RTRNCADR        # TYPE B,             SO STORE RETURN IN
                TS      TEMPSWCH        # TEMPSWCH IN CASE OF AN EVEN PHASE

                CA      PRT2CADR        # SET UP EXIT TO GET TABLE PART OF THIS
                TS      GOLOC +2        # VARIABLE TYPE OF PHASE

                CA      TEMPPHS         # MAKE THE PHASE LOOK RIGHT FOR THE TABLE
                MASK    OCT177          # PART OF THIS VARIABLE PHASE
                TS      TEMPPHS

                EXTEND
                NDX     TEMP2G          # OBTAIN THE JOB:S 2CADR
                DCA     PHSNAME1
                DXCH    GOLOC

ITSAJOB         NDX     TEMP2G          # NOW ADD THE PRIORITY AND LET:S GO
                CA      PHSPRDT1
CHKNOVAC        TS      GOLOC -1        # SAVE PRIO UNTIL WE SEE IF ITS
                EXTEND                  # A FINDVAC OR A NOVAC
                BZMF    ITSNOVAC

                CAF     FVACCADR        # POSITIVE, SET UP FINDVAC CALL.
                XCH     GOLOC -1        # PICK UP PRIO,
                TC      GOLOC -1        # AND GO

ITSNOVAC        CAF     NOVACADR        # NEGATIVE,
                XCH     GOLOC -1        # SET UP NOVAC CALL,
                COM                     # CORRECT PRIO,
                TC      GOLOC -1        # AND GO

ITSATBL         TS      CYR             # FIND OUT IF THE PHASE IS ODD OR EVEN
                CCS     CYR
                TCF     +1              # IT:S EVEN
                TCF     ITSEVEN

                CA      RTRNCADR        # IN CASE THIS IS THE SECOND PART OF A
                TS      GOLOC +2        # TYPE B RESTART, WE NEED PROPER EXIT

                CA      TEMPPHS         # SET UP POINTER FOR FINDING OUR PLACE IN
                TS      SR              # THE RESTART TABLES
                AD      SR

## Page 1295
                NDX     TEMP2G
                AD      SIZETAB +1
                TS      POINTER

CONTBL2         EXTEND                  # FIND OUT WHAT:S IN THE TABLE
                NDX     POINTER
                DCA     CADRTAB         # GET THE 2CADR

                LXCH    GOLOC +1        # STORE THE BB INFORMATION

                CCS     A               # IS IT A JOB OR IS IT  TIMED
                INCR    A               # POSITIVE, MUST BE A JOB
                TCF     ITSAJOB2

                INCR    A               # MUST BE EITHER A WAITLIST OR LONGCALL
                TS      GOLOC           # LET-S STORE THE CORRECT CADR

                CA      WTLTCADR        # SET UP OUR EXIT TO WAITLIST
                TS      GOLOC -1

                CA      GOLOC +1        # NOW FIND OUT IF IT IS A WAITLIST CALL
                MASK    BIT10           # THIS SHOULD BE ONE IF WE HAVE -BB
                CCS     A               # FOR THAT MATTER SO SHOULD BE BITS 9,8,7,
                                        # 6,5, AND LAST BUT NOT LEAST (PERHAPS NOT
                                        # IN IMPORTANCE ANYWAY. BIT 4
                TCF     ITSWTLST        # IT IS A WAITLIST CALL

                NDX     POINTER         # OBTAIN THE ORIGINAL DELTA T
                CA      PRDTTAB         # ADDRESS FOR THIS LONGCALL

                TCF     ITSLGCL1        # NOW GO GET THE DELTA TIME

# ***** THIS MUST BE IN FIXED FIXED *****

                BLOCK   02
                SETLOC  FFTAG2
                BANK

                COUNT*  $$/RSROU
ITSLGCL1        LXCH    GOLOC +1        # OBTAIN THE CORRECT E BANK
                LXCH    BB
                LXCH    GOLOC +1        # AND PRESERVE OUR E AND F BANKS

                EXTEND                  # GET THE DELTA TIME
                NDX     A
                DCA     0

                LXCH    GOLOC +1        # RESTORE OUR E AND F BANK
                LXCH    BB              # RESTORE THE TASKS E AND F BANKS
                LXCH    GOLOC +1        # AND PRESERVE OUR L

## Page 1296
                TCF     ITSLGCL2        # NOW LET:S PROCESS THIS LONGCALL

# ***** YOU  MAY RETURN  TO SWITCHED FIXED *****

                BANK    01
                SETLOC  RESTART
                BANK

                COUNT*  $$/RSROU
ITSLGCL2        DXCH    LONGTIME

                EXTEND                  # CALCULATE TIME LEFT
                DCS     TIME2
                DAS     LONGTIME
                EXTEND
                DCA     LONGBASE
                DAS     LONGTIME

                CCS     LONGTIME        # FIND OUT HOW THIS SHOULD BE RESTARTED
                TCF     LONGCLCL
                TCF     +2
                TCF     IMEDIATE -3
                CCS     LONGTIME +1
                TCF     LONGCLCL
                NOOP                    # CAN:T GET HERE    *********
                TCF     IMEDIATE -3
                TCF     IMEDIATE

LONGCLCL        CA      LGCLCADR        # WE WILL GO TO LONGCALL
                TS      GOLOC -1

                EXTEND                  # PREPARE OUR ENTRY TO LONGCALL
                DCA     LONGTIME
                TC      GOLOC -1

ITSLNGCL        CA      WTLTCADR        # ASSUME IT WILL GO TO WAITLIST
                TS      GOLOC -1

                NDX     TEMP2G
                CS      PHSPRDT1        # GET THE DELTA T ADDRESS

                TCF     ITSLGCL1        # NOW GET THE DELTA TIME

ITSWTLST        CS      GOLOC +1        # CORRECT THE BBCON INFORMATION
                TS      GOLOC +1

                NDX     POINTER         # GET THE DT AND FIND OUT IF IT WAS STORED
                CA      PRDTTAB         # DIRECTLY OR INDIRECTLY

                TCF     TIMETEST        # FIND OUT HOW THE TIME IS STORED

## Page 1297
ITSAJOB2        XCH     GOLOC           # STORE THE CADR

                NDX     POINTER         # ADD THE PRIORITY AND LET:S GO
                CA      PRDTTAB

                TCF     CHKNOVAC

ITSEVEN         CA      TEMPSWCH        # SET UP FOR EITHER THE SECOND PART OF THE
                TS      GOLOC +2        # TABLE, OR A RETURN FOR THE NEXT GROUP

                NDX     TEMP2G          # SET UP POINTER FOR OUR LOCATION WITHIN
                CA      SIZETAB         # THE TABLE
                AD      TEMPPHS         # THIS MAY LOOK BAD BUT LET:S SEE YOU DO
                AD      TEMPPHS         # BETTER IN TIME OR NUMBERR OF LOCATIONS
                AD      TEMPPHS
                TS      POINTER

                TCF     CONTBL2         # NOW PROCESS WHAT IS IN THE TABLE

PHSPART2        CA      THREE           # SET THE POINTER FOR THE SECOND HALF OF
                ADS     POINTER         # THE TABLE

                CA      RTRNCADR        # THIS WILL BE OUR LAST TIME THROUGH THE
                TS      GOLOC +2        # EVEN TABLE , SO AFTER IT  GET THE NEXT
                                        # GROUP
                TCF     CONTBL2         # SO LET:S GET THE SECOND ENTRY IN THE TBL

TEMPPHS         EQUALS  MPAC
TEMP2G          EQUALS  MPAC +1
POINTER         EQUALS  MPAC +2
TEMPSWCH        EQUALS  MPAC +3
GOLOC           EQUALS  VAC5 +20D
MINUS2          EQUALS  NEG2
OCT177          EQUALS  LOW7

PHS2CADR        GENADR  PHSPART2
PRT2CADR        GENADR  GETPART2
LGCLCADR        GENADR  LONGCALL
FVACCADR        =       TCFINDVC
WTLTCADR        =       TCWAIT
NOVACADR        =       TCNOVAC


