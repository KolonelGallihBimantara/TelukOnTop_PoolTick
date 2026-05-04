function login() {
  const user = document.getElementById('username').value;
  const pass = document.getElementById('password').value;

  if (user === "admin" && pass === "admin") {
    // SIMPAN STATUS LOGIN KE BROWSER
    localStorage.setItem('isLoggedIn', 'true');
    
    showDashboard();
  } else { 
    alert("Login Gagal Username atau Password Salah !!!"); 
  }
}

// Fungsi pembantu untuk nampilin dashboard
function showDashboard() {
  document.getElementById('login-page').style.display = "none";
  document.getElementById('dashboard').style.display = "block";
  loadData();
}

// CEK STATUS SAAT REFRESH
if (localStorage.getItem('isLoggedIn') === 'true') {
  showDashboard();
}

function logout() {
  // Hapus memori login
  localStorage.removeItem('isLoggedIn');
  // Refresh halaman
  location.reload();
}