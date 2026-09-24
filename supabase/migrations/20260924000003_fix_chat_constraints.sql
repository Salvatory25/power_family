-- Drop the constraint that prevents a user from chatting with themselves (useful for testing)
ALTER TABLE public.chats DROP CONSTRAINT IF EXISTS participants_must_be_different;

-- Drop the unique index that prevents multiple chats between the same two users
DROP INDEX IF EXISTS unique_chat_participants;

-- Create a new unique index that includes property_id, so a user can have multiple chats 
-- with the same branch manager as long as they are for different properties.
-- We use COALESCE on property_id to handle normal 1-to-1 chats (which have NULL property_id).
-- The UUID '00000000-0000-0000-0000-000000000000' is used as a fallback for NULL.
CREATE UNIQUE INDEX IF NOT EXISTS unique_chat_participants_per_property ON public.chats (
    LEAST(participant1_id, participant2_id),
    GREATEST(participant1_id, participant2_id),
    COALESCE(property_id, '00000000-0000-0000-0000-000000000000'::uuid)
);
