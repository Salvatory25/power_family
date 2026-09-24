-- Allow authenticated users to delete orders (for prototype speed)
CREATE POLICY "Allow all authenticated to delete orders" ON public.orders FOR DELETE USING (auth.role() = 'authenticated');
