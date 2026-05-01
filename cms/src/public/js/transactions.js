// Melakukan checkout untuk semua tiket yang quantity-nya lebih dari 0
async function beliSemua() {
  const buyer = document.getElementById('buyerName').value;
  if (!buyer) return alert("Harap isi NAMA PELANGGAN!");
  
  const selectedTickets = Object.keys(qtyMap).filter(id => qtyMap[id] > 0);
  if (selectedTickets.length === 0) return alert("Pilih minimal 1 tiket!");

  const tickets = await fetch(API_TICKETS).then(r => r.json());

  // Looping untuk mengirim setiap tiket yang dibeli ke API transaksi
  for (let id of selectedTickets) {
    const t = tickets.find(ticket => ticket.id == id);
    const qty = qtyMap[id];
    for (let i = 0; i < qty; i++) {
      await fetch(API_TRANSACTIONS, {
        method: 'POST', headers: {'Content-Type':'application/json'},
        body: JSON.stringify({
          ticketId: t.id, name: buyer, price: t.price, createdAt: new Date().toISOString()
        })
      });
    }
    qtyMap[id] = 0; // Reset quantity setelah beli
  }
  document.getElementById('buyerName').value = "";
  loadData();
  alert("Transaksi Berhasil!");
}

// Menampilkan list transaksi di tab riwayat
function renderTransactions(transactions) {
  const trxEl = document.getElementById('transaksi');
  let total = 0;

  //GROUPING DATA
  const grouped = {};

  transactions.forEach(i => {
    const key = i.name + '-' + (i.ticket?.name || '-');

    if (!grouped[key]) {
      grouped[key] = {
        id: i.id,
        name: i.name,
        ticket: i.ticket?.name || '-',
        qty: 0,
        price: i.price,
        createdAt: i.createdAt
      };
    }

    grouped[key].qty += 1;
    total += i.price;
  });

  //RENDER HASIL GROUP
  trxEl.innerHTML = Object.values(grouped).map(i => {
    return `
      <tr>
        <td>${i.id}</td>
        <td>${i.name}</td>
        <td>${i.ticket} (${i.qty}x)</td>
        <td>${rupiah(i.price * i.qty)}</td>
        <td>${new Date(i.createdAt).toLocaleTimeString()}</td>
        <td>
          <button onclick="hapusTransaksi(${i.id})">X</button>
        </td>
      </tr>
    `;
  }).join('');

  document.getElementById('total').innerText = rupiah(total);
}

// Menghapus satu data transaksi
function hapusTransaksi(id) {
  fetch(`${API_TRANSACTIONS}/${id}`, {method:'DELETE'}).then(loadData);
}

// Menghapus seluruh riwayat transaksi
async function hapusSemuaTransaksi() {
  if (!confirm("Hapus seluruh riwayat transaksi?")) return;
  const trx = await fetch(API_TRANSACTIONS).then(r => r.json());
  for (let t of trx) { await fetch(`${API_TRANSACTIONS}/${t.id}`, { method: 'DELETE' }); }
  loadData();
}

// Fungsi untuk download data ke format Excel .xlsx
async function downloadExcel() {
  const transactions = await fetch(API_TRANSACTIONS).then(r => r.json());

  //GROUPING
  const grouped = {};

  transactions.forEach(i => {
    const key = i.name + '-' + (i.ticket?.name || '-');

    if (!grouped[key]) {
      grouped[key] = {
        name: i.name,
        ticket: i.ticket?.name || '-',
        qty: 0,
        price: i.price,
        createdAt: i.createdAt
      };
    }

    grouped[key].qty += 1;
  });

  //HEADER
  let csv = "No,Nama,Tiket,Qty,Nominal,Waktu\n";
  let no = 1;
  let grandTotal = 0;

  Object.values(grouped).forEach(i => {
    const d = new Date(i.createdAt);

    const waktu = `${d.getDate()}/${d.getMonth()+1}/${d.getFullYear()} ` +
                  `${String(d.getHours()).padStart(2,'0')}.` +
                  `${String(d.getMinutes()).padStart(2,'0')}.` +
                  `${String(d.getSeconds()).padStart(2,'0')}`;

    const total = i.price * i.qty;
    grandTotal += total;

    csv += `${no},${i.name},${i.ticket},${i.qty}x,${total},"${waktu}"\n`;
    no++;
  });

  //TOTAL DI BAWAH
  csv += `\nTOTAL PENDAPATAN,,, ,${grandTotal},\n`;

  //DOWNLOAD
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);

  const a = document.createElement('a');
  a.href = url;
  a.download = 'laporan-transaksi.csv';
  a.click();

  URL.revokeObjectURL(url);
}