// Menyimpan jumlah (quantity) tiket yang dipilih sementara
let qtyMap = {};

// Menampilkan data tiket ke dalam tabel HTML
function renderTickets(tickets) {
  const dataEl = document.getElementById('data');
    dataEl.innerHTML = tickets.map((i, index) => {
    if (qtyMap[i.id] == null) qtyMap[i.id] = 0;
    
    return `
    <tr>
      <td class="py-3 text-center"><span class="badge-id">${index + 1}</span></td>
      <td class="py-3 text-center fw-bold">${i.name}</td>
      <td class="py-3 text-center text-success fw-bold">${rupiah(i.price)}</td>
      <td class="py-3 text-center">
        <div class="d-flex align-items-center justify-content-center gap-2">
          <div class="qty-box">
            <!-- PENTING: Bagian onclick TETAP pakai i.id (ID Asli Database) -->
            <button onclick="changeQty(${i.id}, -1)" class="btn-qty">-</button>
            <span id="qty-${i.id}" class="qty-val">${qtyMap[i.id]}</span>
            <button onclick="changeQty(${i.id}, 1)" class="btn-qty">+</button>
          </div>
          <button onclick="editTiket(${i.id}, '${i.name}', ${i.price})" class="btn btn-action btn-warning text-white"><i class="bi bi-pencil-fill"></i></button>
          <button onclick="hapusTiket(${i.id})" class="btn btn-action btn-outline-danger"><i class="bi bi-trash-fill"></i></button>
        </div>
      </td>
    </tr>`;
  }).join('');
}

// Menambah atau mengurangi angka quantity di tabel
function changeQty(id, change) {
  qtyMap[id] += change;
  if (qtyMap[id] < 0) qtyMap[id] = 0;
  document.getElementById(`qty-${id}`).innerText = qtyMap[id];
}

// Memasukkan data tiket yang dipilih ke dalam form edit
function editTiket(id, name, price) {
  document.getElementById('editId').value = id;
  document.getElementById('name').value = name;
  document.getElementById('price').value = price;
  document.getElementById('btnSave').innerHTML = '<i class="bi bi-arrow-repeat me-2"></i>Perbarui Data Tiket';
  document.getElementById('btnSave').className = 'btn btn-warning py-3 fw-bold rounded-3 shadow text-white';
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Kirim data ke API (Bisa POST untuk baru atau PATCH untuk edit)
async function submitTiket() {
  const id = document.getElementById('editId').value;
  const name = document.getElementById('name').value;
  const price = parseInt(document.getElementById('price').value);
  if (!name || !price) return alert("Lengkapi data!");

  const method = id ? 'PATCH' : 'POST';
  const url = id ? `${API_TICKETS}/${id}` : API_TICKETS;

  await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'kolamrenang2026'
    },
    body: JSON.stringify({ name, price })
  });
  resetForm();
  loadData(); // Refresh tabel setelah simpan
}

// Mengosongkan kembali form tiket
function resetForm() {
  document.getElementById('editId').value = "";
  document.getElementById('name').value = "";
  document.getElementById('price').value = "";
  document.getElementById('btnSave').innerHTML = '<i class="bi bi-save me-2"></i>Simpan Data Tiket';
  document.getElementById('btnSave').className = 'btn btn-primary py-3 fw-bold rounded-3 shadow';
}

// Menghapus tiket dari katalog (dengan validasi apakah sudah ada transaksi atau belum)
async function hapusTiket(id) {
  if (!confirm("Hapus tiket ini dari katalog?")) return;
  const trx = await fetch(API_TRANSACTIONS, {
    headers: {
      'x-api-key': 'kolamrenang2026'
    }
  }).then(r => r.json());
  if (trx.some(t => t.ticketId == id)) return alert("Gagal: Tiket ini masih memiliki data transaksi!");
  await fetch(`${API_TICKETS}/${id}`, {
    method: 'DELETE',
    headers: {
      'x-api-key': 'kolamrenang2026'
    }
  });
  loadData();
}