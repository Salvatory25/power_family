-- ============================================================================
-- POWER FAMILY INVESTMENT - CHAT SYSTEM SCHEMA
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant1_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    participant2_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    last_message TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT participants_must_be_different CHECK (participant1_id != participant2_id)
);

-- Ensure a unique chat per pair of users
CREATE UNIQUE INDEX IF NOT EXISTS unique_chat_participants ON public.chats (
    LEAST(participant1_id, participant2_id),
    GREATEST(participant1_id, participant2_id)
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- RLS for chats
CREATE POLICY "Users can view their own chats" ON public.chats
    FOR SELECT
    USING (auth.uid() = participant1_id OR auth.uid() = participant2_id);

CREATE POLICY "Users can insert chats they are a part of" ON public.chats
    FOR INSERT
    WITH CHECK (auth.uid() = participant1_id OR auth.uid() = participant2_id);

CREATE POLICY "Users can update their own chats" ON public.chats
    FOR UPDATE
    USING (auth.uid() = participant1_id OR auth.uid() = participant2_id);

-- RLS for messages
CREATE POLICY "Users can view messages in their chats" ON public.messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = messages.chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert messages in their chats" ON public.messages
    FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid())
        )
    );

CREATE POLICY "Users can update read status of messages in their chats" ON public.messages
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE chats.id = messages.chat_id 
            AND (chats.participant1_id = auth.uid() OR chats.participant2_id = auth.uid())
        )
    );

-- Trigger to update last_message and updated_at on chats table
CREATE OR REPLACE FUNCTION public.update_chat_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.chats
  SET 
    last_message = NEW.content,
    last_message_at = NEW.created_at,
    updated_at = NEW.created_at
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS update_chat_last_message_trigger ON public.messages;
CREATE TRIGGER update_chat_last_message_trigger
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.update_chat_last_message();

-- Enable real-time for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chats;
