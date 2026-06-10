const API_TICKETS = 'http://localhost:3000/tickets';
const API_TRANSACTIONS = 'http://localhost:3000/transactions';

async function loadData() {
  try {
    const [ticketsRes, transactionsRes] = await Promise.all([
      fetch(API_TICKETS, {
        headers: {
          "x-api-key": "kolamrenang2026"
        }
      }),
      fetch(API_TRANSACTIONS, {
        headers: {
          "x-api-key": "kolamrenang2026"
        }
      })
    ]);

    const tickets = await ticketsRes.json();
    const transactions = await transactionsRes.json();

    renderTickets(tickets);
    renderTransactions(transactions, tickets);

  } catch (err) {
    console.error("Gagal load data dari API:", err);
  }
}