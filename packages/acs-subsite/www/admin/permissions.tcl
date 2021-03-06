ad_page_contract {
    Permissions for the subsite itself.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-06-13
    @cvs-id $Id: permissions.tcl,v 1.4 2015/12/04 13:50:08 cvs Exp $
}

set page_title "[ad_conn instance_name] Permissions"

set context [list "Permissions"]

set subsite_id [ad_conn subsite_id]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
