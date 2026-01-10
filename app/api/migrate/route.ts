import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export async function POST(request: NextRequest) {
  try {
    console.log('🔵 Running migration...');

    // Add review_status column
    const { error: error1 } = await supabaseAdmin.rpc('exec_sql', {
      sql_query: `
        ALTER TABLE leads
        ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending'
        CHECK (review_status IN ('pending', 'yet_to_review', 'reviewed'));
      `
    }).catch(() => ({ error: null }));

    // Add reviewed_by column
    const { error: error2 } = await supabaseAdmin.rpc('exec_sql', {
      sql_query: `
        ALTER TABLE leads
        ADD COLUMN IF NOT EXISTS reviewed_by UUID;
      `
    }).catch(() => ({ error: null }));

    // Update existing WIN leads
    const { error: error3 } = await supabaseAdmin
      .from('leads')
      .update({ review_status: 'pending' })
      .eq('status', 'win')
      .is('review_status', null);

    console.log('✅ Migration completed');

    return NextResponse.json({
      success: true,
      message: 'Migration completed successfully',
      errors: { error1, error2, error3 }
    });
  } catch (error) {
    console.error('❌ Migration failed:', error);
    return NextResponse.json(
      { success: false, error: 'Migration failed' },
      { status: 500 }
    );
  }
}
