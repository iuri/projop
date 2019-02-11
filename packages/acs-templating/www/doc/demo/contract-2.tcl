ad_page_contract {
  @cvs-id $Id: contract-2.tcl,v 1.5 2015/12/04 13:50:14 cvs Exp $
} {
  count:naturalnum
  noun:notnull,nohtml
  { plural:nohtml "" }
} -validate {
  supersticion -requires {count} {
    if {$count == 13} {
      ad_complain
    }
  }
} -errors {
  supersticion {This number brings you no luck.}
} -properties {
  phrase:onevalue
} -return_errors error_list

if {[info exists error_list]} {
  # divert to error-handling page
  ad_return_template "contract-err"
} else {
  set phrase "You've got "
  
  if {$count == 1} {
    append phrase "one $noun"
  } else {
    if {$plural eq ""} {
      set plural "${noun}s"
    }
    append phrase "$count $plural"
  }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End: