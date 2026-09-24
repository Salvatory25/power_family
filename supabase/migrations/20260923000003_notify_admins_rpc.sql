CREATE OR REPLACE FUNCTION public.notify_admins_and_manager(
    p_branch_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_type TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Notify SUPER_ADMINs
    FOR v_user_id IN 
        SELECT id FROM public.profiles WHERE primary_role = 'SUPER_ADMIN'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, is_read, created_at)
        VALUES (v_user_id, p_title, p_message, p_type, false, now());
    END LOOP;

    -- Notify BRANCH_MANAGER for the specific branch
    IF p_branch_id IS NOT NULL THEN
        FOR v_user_id IN 
            SELECT id FROM public.profiles WHERE primary_role = 'BRANCH_MANAGER' AND branch_id = p_branch_id
        LOOP
            -- Prevent duplicate if branch manager is also a super admin (rare but possible)
            IF NOT EXISTS (
                SELECT 1 FROM public.notifications 
                WHERE user_id = v_user_id AND message = p_message AND created_at > now() - interval '1 minute'
            ) THEN
                INSERT INTO public.notifications (user_id, title, message, type, is_read, created_at)
                VALUES (v_user_id, p_title, p_message, p_type, false, now());
            END IF;
        END LOOP;
    END IF;
END;
$$;
