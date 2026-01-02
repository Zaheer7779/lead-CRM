'use client';

import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { LeadWithDetails } from '@/lib/types';

interface CustomerData {
  phone: string;
  name: string;
  leadCount: number;
  winCount: number;
  lostCount: number;
  totalValue: number;
  firstVisit: string;
  lastVisit: string;
}

export default function CustomerHistoryPage() {
  const router = useRouter();
  const params = useParams();
  const phone = params.phone as string;

  const [customer, setCustomer] = useState<CustomerData | null>(null);
  const [leads, setLeads] = useState<LeadWithDetails[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCustomerHistory();
  }, [phone]);

  const fetchCustomerHistory = async () => {
    try {
      const response = await fetch(`/api/customers/${phone}`);
      const data = await response.json();

      if (data.success) {
        setCustomer(data.data.customer);
        setLeads(data.data.leads);
      }
    } catch (error) {
      console.error('Error fetching customer history:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-gray-500">Loading customer history...</div>
      </div>
    );
  }

  if (!customer) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-500 mb-4">Customer not found</p>
          <button
            onClick={() => router.back()}
            className="text-blue-600 hover:underline"
          >
            Go Back
          </button>
        </div>
      </div>
    );
  }

  const winPercentage = customer.leadCount > 0
    ? ((customer.winCount / customer.leadCount) * 100).toFixed(0)
    : 0;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <button
            onClick={() => router.back()}
            className="text-blue-600 hover:underline mb-3 text-sm"
          >
            ← Back
          </button>
          <h1 className="text-2xl font-bold text-gray-900">Customer History</h1>
        </div>
      </div>

      {/* Customer Summary */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h2 className="text-xl font-semibold text-gray-900">{customer.name}</h2>
              <p className="text-gray-600">{customer.phone}</p>
            </div>
            {customer.leadCount > 1 && (
              <span className="px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-sm font-semibold">
                🔁 Repeat Customer ({customer.leadCount} visits)
              </span>
            )}
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-xs text-gray-500 mb-1">Total Leads</p>
              <p className="text-2xl font-bold text-gray-900">{customer.leadCount}</p>
            </div>
            <div className="bg-green-50 rounded-lg p-4">
              <p className="text-xs text-gray-500 mb-1">Wins</p>
              <p className="text-2xl font-bold text-green-600">{customer.winCount}</p>
            </div>
            <div className="bg-red-50 rounded-lg p-4">
              <p className="text-xs text-gray-500 mb-1">Lost</p>
              <p className="text-2xl font-bold text-red-600">{customer.lostCount}</p>
            </div>
            <div className="bg-blue-50 rounded-lg p-4">
              <p className="text-xs text-gray-500 mb-1">Win Rate</p>
              <p className="text-2xl font-bold text-blue-600">{winPercentage}%</p>
            </div>
          </div>

          <div className="mt-4 pt-4 border-t grid grid-cols-2 gap-4 text-sm">
            <div>
              <p className="text-gray-500">Total Value</p>
              <p className="font-semibold text-gray-900">₹{customer.totalValue.toLocaleString('en-IN')}</p>
            </div>
            <div>
              <p className="text-gray-500">First Visit</p>
              <p className="font-semibold text-gray-900">{formatDate(customer.firstVisit)}</p>
            </div>
          </div>
        </div>

        {/* Timeline */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Visit History</h3>

          <div className="space-y-4">
            {leads.map((lead, index) => {
              const isWin = lead.status === 'win';
              return (
                <div
                  key={lead.id}
                  className={`border-l-4 ${
                    isWin ? 'border-green-500 bg-green-50' : 'border-red-500 bg-red-50'
                  } p-4 rounded-r-lg`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <span
                        className={`px-2 py-1 rounded text-xs font-semibold ${
                          isWin ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}
                      >
                        {isWin ? '✓ Win' : '✗ Lost'}
                      </span>
                      {index === 0 && (
                        <span className="ml-2 text-xs text-gray-500 font-semibold">Latest</span>
                      )}
                    </div>
                    <span className="text-xs text-gray-500">{formatDate(lead.created_at)}</span>
                  </div>

                  <div className="grid grid-cols-2 gap-4 text-sm mt-3">
                    <div>
                      <p className="text-gray-500">Category</p>
                      <p className="font-medium text-gray-900">{lead.category_name || 'N/A'}</p>
                    </div>
                    <div>
                      <p className="text-gray-500">{isWin ? 'Invoice' : 'Model'}</p>
                      <p className="font-medium text-gray-900">
                        {isWin ? lead.invoice_no : lead.model_name || 'N/A'}
                      </p>
                    </div>
                    <div>
                      <p className="text-gray-500">Amount</p>
                      <p className={`font-bold ${isWin ? 'text-green-600' : 'text-blue-600'}`}>
                        ₹{(isWin ? (lead.sale_price || 0) : (lead.deal_size || 0)).toLocaleString('en-IN')}
                      </p>
                    </div>
                    <div>
                      <p className="text-gray-500">Sales Rep</p>
                      <p className="font-medium text-gray-900">{lead.sales_rep_name || 'N/A'}</p>
                    </div>
                    {!isWin && lead.not_today_reason && (
                      <div className="col-span-2">
                        <p className="text-gray-500">Reason</p>
                        <p className="font-medium text-gray-900">
                          {lead.not_today_reason === 'other' && lead.other_reason
                            ? `Other: ${lead.other_reason}`
                            : lead.not_today_reason === 'need_family_approval'
                            ? 'Need family approval'
                            : lead.not_today_reason === 'price_high'
                            ? 'Price concern'
                            : lead.not_today_reason === 'want_more_options'
                            ? 'Want more options'
                            : 'Just browsing'}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
