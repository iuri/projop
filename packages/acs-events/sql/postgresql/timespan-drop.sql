-- packages/acs-events/sql/timespan-drop.sql
--
-- Drop the data models and API for both time_interval and timespan.
--
-- @author W. Scott Meeks
--
-- $Id: timespan-drop.sql,v 1.5 2016/01/12 17:45:44 cvs Exp $

select drop_package('timespan');
drop index   timespans_idx;
drop table   timespans;

select drop_package('time_interval');
drop table   time_intervals;

drop view if exists timespan_seq;
drop sequence timespan_sequence;
