-- Add property and branch context to chats
ALTER TABLE public.chats 
ADD COLUMN IF NOT EXISTS property_id UUID REFERENCES public.plots(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL;

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can view their own chats" ON public.chats;
DROP POLICY IF EXISTS "Users can insert chats they are a part of" ON public.chats;
DROP POLICY IF EXISTS "Users can update their own chats" ON public.chats;
DROP POLICY IF EXISTS "Users can view messages in their chats" ON public.messages;
DROP POLICY IF EXISTS "Users can insert messages in their chats" ON public.messages;
DROP POLICY IF EXISTS "Users can update read status of messages in their chats" ON public.messages;

-- Helper function to check if user is admin or branch manager for the chat
CREATE OR REPLACE FUNCTION public.is_admin_or_branch_manager(chat_branch_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_branch UUID;
BEGIN
    SELECT primary_role, branch_id INTO user_role, user_branch FROM public.profiles WHERE id = auth.uid();
    IF user_role IN ('SUPER_ADMIN', 'SYSTEM_ADMIN') THEN
        RETURN TRUE;
    END IF;
    IF user_role IN ('BRANCH_MANAGER', 'SALES_AGENT') AND user_branch = chat_branch_id THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- New RLS for chats
CREATE POLICY "Chats view policy" ON public.chats
    FOR SELECT
    USING (
        auth.uid() = participant1_id OR 
        auth.uid() = participant2_id OR
        public.is_admin_or_branch_manager(branch_id)
    );

CREATE POLICY "Chats insert policy" ON public.chats
    FOR INSERT
    WITH CHECK (
        auth.uid() = participant1_id OR 
        auth.uid() = participant2_id OR
        public.is_admin_or_branch_manager(branch_id)
    );

CREATE POLICY "Chats update policy" ON public.chats
    FOR UPDATE
    USING (
        auth.uid() = participant1_id OR 
        auth.uid() = participant2_id OR
        public.is_admin_or_branch_manager(branch_id)
    );

-- New RLS for messages
CREATE POLICY "Messages view policy" ON public.messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = messages.chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid() OR public.is_admin_or_branch_manager(chats.branch_id))
        )
    );

CREATE POLICY "Messages insert policy" ON public.messages
    FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid() OR public.is_admin_or_branch_manager(chats.branch_id))
        )
    );

CREATE POLICY "Messages update policy" ON public.messages
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = messages.chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid() OR public.is_admin_or_branch_manager(chats.branch_id))
        )
    );
