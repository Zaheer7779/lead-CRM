# Lead CRM - Setup Guide

This is a complete multi-tenant Lead CRM system with PIN-based authentication, built with Next.js 14, TypeScript, and Supabase.

## Features

- 🔐 **Secure PIN Authentication** - No OTP costs, simple 4-digit PIN system
- 🏢 **Multi-Tenant** - Each organization has isolated data
- 👥 **Role-Based Access** - Admin and Sales Rep roles
- 📊 **Lead Management** - Track customer leads with detailed information
- 🎨 **Custom Branding** - Organization logo upload
- 📱 **Mobile-First** - Optimized for mobile devices
- 💬 **WhatsApp Integration** - Send automated messages to leads

## Prerequisites

- Node.js 18+ installed
- A Supabase account (free tier works)
- Git installed

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/arsalan507/lead-CRM.git
cd lead-CRM
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up Supabase

1. Go to [Supabase](https://supabase.com) and create a new project
2. Wait for the project to be ready (2-3 minutes)
3. Go to **SQL Editor** in your Supabase dashboard
4. Copy the entire contents of `supabase-setup-complete.sql`
5. Paste it into the SQL Editor and click **Run**
6. Wait for the script to complete (you should see "✅ Database setup complete!")

### 4. Configure Environment Variables

1. Copy the example environment file:

```bash
cp .env.example .env.local
```

2. Get your Supabase credentials:
   - Go to **Project Settings** → **API**
   - Copy the **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - Copy the **anon/public** key
   - Copy the **service_role** key (keep this secret!)

3. Edit `.env.local` and add your credentials:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# JWT Secret (generate a random string)
JWT_SECRET=your-random-secret-key-here
```

**To generate a JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 5. Run the Application

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## First-Time Usage

### Create Your Organization

1. Visit `http://localhost:3000/login`
2. Click **"Don't have an account? Sign up"**
3. Fill in the registration form:
   - **Organization Name** - Your company name
   - **Your Name** - Admin name
   - **Phone Number** - 10-digit phone (will be used for login)
   - **Create 4-Digit PIN** - Choose a secure 4-digit PIN
4. Click **"Create Organization"**
5. You'll be logged in as the admin

### Add Team Members (Sales Reps)

1. After logging in as admin, click **"Manage Team"**
2. Click **"+ Add Sales Rep"**
3. Enter:
   - Name
   - Phone Number (10 digits)
   - 4-Digit PIN (set a PIN for them)
4. Click **"Add Member"**
5. Share the phone number and PIN with the sales rep

### Reset a Team Member's PIN

1. Go to **Manage Team**
2. Find the team member
3. Click **"Reset PIN"**
4. Enter a new 4-digit PIN
5. Click **"Confirm"**
6. Share the new PIN with the team member

## User Roles

### Admin
- View all leads from all sales reps
- Add/manage team members
- Set and reset PINs for sales reps
- Configure organization settings (logo, WhatsApp)
- Manage categories and models
- Export leads to CSV

### Sales Rep
- Create new leads
- View only their own leads
- Cannot change their own PIN
- Cannot access admin features

## Deployment to Vercel

### 1. Push to GitHub

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Deploy to Vercel

1. Go to [Vercel](https://vercel.com)
2. Click **"Add New Project"**
3. Import your GitHub repository
4. Add environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `JWT_SECRET`
5. Click **"Deploy"**

### 3. Configure Custom Domain (Optional)

1. Go to your project settings in Vercel
2. Click **"Domains"**
3. Add your custom domain
4. Update DNS settings as instructed

## Key Files

- `supabase-setup-complete.sql` - Complete database setup script
- `app/api/` - All API endpoints
- `app/admin/` - Admin dashboard pages
- `app/dashboard/` - Sales rep dashboard
- `app/login/` - Login and registration
- `lib/auth.ts` - Authentication helpers
- `lib/supabase.ts` - Supabase client
- `middleware.ts` - Authentication middleware

## Security Features

✅ PIN Authentication (no SMS costs)
✅ bcrypt password hashing (10 rounds)
✅ JWT token-based sessions (7-day expiry)
✅ Row Level Security (RLS) in Supabase
✅ Multi-tenant data isolation
✅ Admin-only PIN reset
✅ Organization-scoped API access
✅ Middleware authentication on all protected routes

## Troubleshooting

### "User already exists" error
- The phone number is already registered
- Try a different phone number or reset the database

### "Unauthorized" error
- Make sure you're logged in
- Check that your JWT_SECRET is set correctly
- Try logging out and logging back in

### Database connection error
- Verify your Supabase credentials in `.env.local`
- Make sure the Supabase project is active
- Check that the database setup script ran successfully

### Build errors on Vercel
- Ensure all environment variables are set in Vercel
- Check the build logs for specific errors
- Verify that your Supabase project is accessible from Vercel

## Support

For issues and questions:
- Create an issue on GitHub: https://github.com/arsalan507/lead-CRM/issues
- Check existing issues for solutions

## License

MIT License - feel free to use this for your own projects!
