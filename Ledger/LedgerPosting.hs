{-|

A compound data type for efficiency. A 'LedgerPosting' is a 'Posting' with
its parent 'LedgerTransaction' \'s date and description attached. The
\"transaction\" term is pretty ingrained in the code, docs and with users,
so we've kept it. These are what we work with most of the time when doing
reports.

-}

module Ledger.LedgerPosting
where
import Ledger.Dates
import Ledger.Utils
import Ledger.Types
import Ledger.LedgerTransaction (showAccountName)
import Ledger.Amount


instance Show LedgerPosting where show=showLedgerPosting

showLedgerPosting :: LedgerPosting -> String
showLedgerPosting (LedgerPosting _ stat d desc a amt ttype) = 
    s ++ unwords [showDate d,desc,a',show amt,show ttype]
    where s = if stat then " *" else ""
          a' = showAccountName Nothing ttype a

-- | Convert a 'LedgerTransaction' to two or more 'LedgerPosting's. An id number
-- is attached to the transactions to preserve their grouping - it should
-- be unique per entry.
flattenLedgerTransaction :: (LedgerTransaction, Int) -> [LedgerPosting]
flattenLedgerTransaction (LedgerTransaction d _ s _ desc _ ps _, n) = 
    [LedgerPosting n s d desc (paccount p) (pamount p) (ptype p) | p <- ps]

accountNamesFromLedgerPostings :: [LedgerPosting] -> [AccountName]
accountNamesFromLedgerPostings = nub . map taccount

sumLedgerPostings :: [LedgerPosting] -> MixedAmount
sumLedgerPostings = sum . map tamount

nulltxn :: LedgerPosting
nulltxn = LedgerPosting 0 False (parsedate "1900/1/1") "" "" nullmixedamt RegularPosting

-- | Does the given transaction fall within the given date span ?
isLedgerPostingInDateSpan :: DateSpan -> LedgerPosting -> Bool
isLedgerPostingInDateSpan (DateSpan Nothing Nothing)   _ = True
isLedgerPostingInDateSpan (DateSpan Nothing (Just e))  (LedgerPosting{tdate=d}) = d<e
isLedgerPostingInDateSpan (DateSpan (Just b) Nothing)  (LedgerPosting{tdate=d}) = d>=b
isLedgerPostingInDateSpan (DateSpan (Just b) (Just e)) (LedgerPosting{tdate=d}) = d>=b && d<e

