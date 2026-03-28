--Purpose: Change a user from EXPIRED to OPEN by setting a user's password to the same value.
--This PL/SQL block requires elevated privileges and should be run as SYS.
--This task is difficult because we need to temporarily change profiles to avoid
--  errors like "ORA-28007: the password cannot be reused".
--
--How to use: Run as SYS in SQL*Plus and enter the username when prompted.
--  If using another IDE, manually replace the variable two lines below.
declare
    v_username varchar2(128) := trim(upper('&USERNAME'));
    --Do not change anything below this line.
    v_profile                 varchar2(128);
    v_old_password_reuse_time varchar2(128);
    v_uses_default_for_time   varchar2(3);
    v_old_password_reuse_max  varchar2(128);
    v_uses_default_for_max    varchar2(3);
    v_alter_user_sql          varchar2(4000);
begin
    --Get user's profile information.
    --(This is tricky because there could be an indirection to the DEFAULT profile.
    select
        profile,
        case when user_password_reuse_time = 'DEFAULT' then default_password_reuse_time else user_password_reuse_time end password_reuse_time,
        case when user_password_reuse_time = 'DEFAULT' then 'Yes' else 'No' end uses_default_for_time,
        case when user_password_reuse_max  = 'DEFAULT' then default_password_reuse_max  else user_password_reuse_max  end password_reuse_max,
        case when user_password_reuse_max  = 'DEFAULT' then 'Yes' else 'No' end uses_default_for_max
    into v_profile, v_old_password_reuse_time, v_uses_default_for_time, v_old_password_reuse_max, v_uses_default_for_max
    from
    (
        --User's profile information.
        select
            dba_profiles.profile,
            max(case when resource_name = 'PASSWORD_REUSE_TIME' then limit else null end) user_password_reuse_time,
            max(case when resource_name = 'PASSWORD_REUSE_MAX' then limit else null end) user_password_reuse_max
        from dba_profiles
        join dba_users
            on dba_profiles.profile = dba_users.profile
        where username = v_username
        group by dba_profiles.profile
    ) users_profile
    cross join
    (
        --Default profile information.
        select
            max(case when resource_name = 'PASSWORD_REUSE_TIME' then limit else null end) default_password_reuse_time,
            max(case when resource_name = 'PASSWORD_REUSE_MAX' then limit else null end) default_password_reuse_max
        from dba_profiles
        where profile = 'DEFAULT'
    ) default_profile;

    --Get user's password information.
    select
        'alter user '||name||' identified by values '''||
        spare4 || case when password is not null then ';' else null end || password ||
        ''''
    into v_alter_user_sql
    from sys.user$
    where name = v_username;

    --Change profile limits, if necessary.
    if v_old_password_reuse_time <> 'UNLIMITED' then
        execute immediate 'alter profile '||v_profile||' limit password_reuse_time unlimited';
    end if;

    if v_old_password_reuse_max <> 'UNLIMITED' then
        execute immediate 'alter profile '||v_profile||' limit password_reuse_max unlimited';
    end if;

    --Change the user's password.
    execute immediate v_alter_user_sql;

    --Change the profile limits back, if necessary.
    if v_old_password_reuse_time <> 'UNLIMITED' then
        if v_uses_default_for_time = 'Yes' then
            execute immediate 'alter profile '||v_profile||' limit password_reuse_time default';
        else
            execute immediate 'alter profile '||v_profile||' limit password_reuse_time '||v_old_password_reuse_time;
        end if;
    end if;

    if v_old_password_reuse_max <> 'UNLIMITED' then
        if v_uses_default_for_max = 'Yes' then
            execute immediate 'alter profile '||v_profile||' limit password_reuse_max default';
        else
            execute immediate 'alter profile '||v_profile||' limit password_reuse_max '||v_old_password_reuse_max;
        end if;
    end if;
end;
/