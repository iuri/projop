-- @cvs-id $Id: upgrade-5.2.0d2-5.2.0d3.sql,v 1.4 2015/12/04 13:49:58 cvs Exp $
-- @author davis@xarg.net
-- cascade on delete of folder and of content_type
alter table cr_folder_type_map drop constraint cr_folder_type_map_fldr_fk;
alter table cr_folder_type_map add constraint cr_folder_type_map_fldr_fk
        foreign key (folder_id) references cr_folders on delete cascade;


alter table cr_folder_type_map drop constraint cr_folder_type_map_typ_fk;
alter table cr_folder_type_map add constraint cr_folder_type_map_typ_fk
        foreign key (content_type) references acs_object_types on delete cascade;
