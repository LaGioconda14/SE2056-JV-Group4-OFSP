/* Biểu đồ trang Tổng quan Shop (Chart.js) */
function formatVnd(v) {
  return new Intl.NumberFormat('vi-VN').format(v) + ' ₫';
}
function formatVndShort(v) {
  if (v >= 1e9) return (v / 1e9).toFixed(1).replace(/\.0$/, '') + ' tỷ';
  if (v >= 1e6) return (v / 1e6).toFixed(1).replace(/\.0$/, '') + ' tr';
  if (v >= 1e3) return Math.round(v / 1e3) + 'k';
  return v;
}

function initDashboardCharts(cfg) {
  if (typeof Chart === 'undefined') return;
  Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
  Chart.defaults.color = '#64748b';

  // --- Doanh thu (cột) + số đơn (đường) ---
  const trendEl = document.getElementById('trendChart');
  if (trendEl) {
    new Chart(trendEl, {
      data: {
        labels: cfg.trend.labels,
        datasets: [
          {
            type: 'bar', label: 'Doanh thu', data: cfg.trend.revenue, yAxisID: 'y',
            backgroundColor: 'rgba(16,185,129,.85)', borderRadius: 6, maxBarThickness: 28
          },
          {
            type: 'line', label: 'Số đơn', data: cfg.trend.orders, yAxisID: 'y1',
            borderColor: '#f97316', backgroundColor: '#f97316', tension: .35, pointRadius: 3, borderWidth: 2
          }
        ]
      },
      options: {
        responsive: true, maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { position: 'bottom', labels: { usePointStyle: true, boxWidth: 8 } },
          tooltip: {
            callbacks: {
              label: ctx => ctx.dataset.yAxisID === 'y'
                ? ' Doanh thu: ' + formatVnd(ctx.parsed.y)
                : ' Số đơn: ' + ctx.parsed.y
            }
          }
        },
        scales: {
          x: { grid: { display: false }, ticks: { maxRotation: 0, autoSkip: true, maxTicksLimit: 12 } },
          y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { callback: formatVndShort } },
          y1: { beginAtZero: true, position: 'right', grid: { display: false }, ticks: { precision: 0 } }
        }
      }
    });
  }

  // --- Cơ cấu trạng thái đơn ---
  const statusEl = document.getElementById('statusChart');
  if (statusEl) {
    new Chart(statusEl, {
      type: 'doughnut',
      data: {
        labels: cfg.status.labels,
        datasets: [{
          data: cfg.status.values,
          backgroundColor: ['#f59e0b', '#38bdf8', '#818cf8', '#a78bfa', '#10b981', '#ef4444', '#94a3b8'],
          borderWidth: 2, borderColor: '#fff'
        }]
      },
      options: {
        responsive: true, maintainAspectRatio: false, cutout: '62%',
        plugins: { legend: { position: 'right', labels: { usePointStyle: true, boxWidth: 8, font: { size: 11 } } } }
      }
    });
  }
}
