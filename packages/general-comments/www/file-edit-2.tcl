# /packages/general-comments/www/file-edit-2.tcl

ad_page_contract {
    Edit the title for a file attachment

    @param attach_id  The id of the attachment to edit
    @param parent_id  The id of the comment this attachment refers to
    @param title      The value of the new title

    @author Phong Nguyen (phong@arsdigita.com)
    @author Pascal Scheffers (pascal@scheffers.net)
    @creation-date 2000-10-12
    @cvs-id $Id: file-edit-2.tcl,v 1.4 2015/12/04 14:02:55 cvs Exp $
} {
    attach_id:naturalnum,notnull
    parent_id:naturalnum,notnull
    title:notnull
    { return_url {} }
}

# check to see if the user can edit this comment
permission::require_permission -object_id $attach_id -privilege write

db_1row get_revision_id {
    select content_item.get_latest_revision(:attach_id) as revision_id from dual
}
db_dml edit_title {
    update cr_revisions
       set title = :title
     where revision_id = :revision_id
}
    
ad_returnredirect [export_vars -base view-comment {{comment_id $parent_id} return_url}]




# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
