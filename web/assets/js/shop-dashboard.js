/**
 * Interactive Scripts for Shop Dashboard
 */

document.addEventListener("DOMContentLoaded", () => {
    // 1. Order Status Filter Tabs
    const filterTabs = document.querySelectorAll(".order-filter-tab");
    const orderRows = document.querySelectorAll(".order-row");

    filterTabs.forEach(tab => {
        tab.addEventListener("click", () => {
            filterTabs.forEach(t => t.classList.remove("active"));
            tab.classList.add("active");

            const filter = tab.getAttribute("data-filter");
            orderRows.forEach(row => {
                if (filter === "all" || row.getAttribute("data-status") === filter) {
                    row.classList.remove("hidden");
                } else {
                    row.classList.add("hidden");
                }
            });
        });
    });

    // 2. Receiving Orders Toggle
    const orderToggle = document.getElementById("orderReceivingToggle");
    const toggleLabel = document.getElementById("toggleStatusText");

    if (orderToggle) {
        orderToggle.addEventListener("change", (e) => {
            if (toggleLabel) {
                toggleLabel.textContent = e.target.checked ? "Đang nhận đơn" : "Tạm ngưng nhận đơn";
            }
        });
    }

    // 3. Refresh Button
    const refreshBtn = document.getElementById("btnRefreshDash");
    if (refreshBtn) {
        refreshBtn.addEventListener("click", () => {
            const icon = refreshBtn.querySelector("i");
            if (icon) icon.classList.add("fa-spin");
            setTimeout(() => {
                if (icon) icon.classList.remove("fa-spin");
                window.location.reload();
            }, 600);
        });
    }

    // 4. Render 7-Day Mixed Chart (Bar + Line)
    renderRevenueChart();
});

function renderRevenueChart() {
    const ctx = document.getElementById("revenueWeeklyChart");
    if (!ctx) return;

    // Check if Chart.js is loaded
    if (typeof Chart !== "undefined") {
        const labels = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "CN (Nay)"];
        const revenueData = [12.5, 15.8, 14.2, 18.0, 20.5, 24.2, 14.8]; // Triệu VNĐ
        const ordersData = [25, 32, 28, 38, 42, 54, 38]; // Số đơn

        new Chart(ctx, {
            data: {
                labels: labels,
                datasets: [
                    {
                        type: "line",
                        label: "Số đơn hàng",
                        data: ordersData,
                        borderColor: "#ea580c",
                        backgroundColor: "#ea580c",
                        borderWidth: 2.5,
                        tension: 0.35,
                        pointBackgroundColor: "#ea580c",
                        pointRadius: 4.5,
                        pointHoverRadius: 6,
                        yAxisID: "y1"
                    },
                    {
                        type: "bar",
                        label: "Doanh thu (triệu đ)",
                        data: revenueData,
                        backgroundColor: (context) => {
                            // Highlight Thứ 7 with deep primary green
                            return context.dataIndex === 5 ? "#166534" : "#bbf7d0";
                        },
                        borderRadius: 8,
                        barThickness: 28,
                        yAxisID: "y"
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: "index",
                    intersect: false
                },
                plugins: {
                    legend: {
                        display: false // Using custom HTML legend in mockup
                    },
                    tooltip: {
                        backgroundColor: "#1f2937",
                        padding: 10,
                        titleFont: { size: 12, weight: "bold" },
                        bodyFont: { size: 11 },
                        callbacks: {
                            label: function(context) {
                                if (context.dataset.type === "bar") {
                                    return `Doanh thu: ${context.parsed.y} triệu ₫`;
                                } else {
                                    return `Số đơn: ${context.parsed.y} đơn`;
                                }
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: {
                            font: { size: 11, weight: "600" },
                            color: (context) => {
                                return context.index === 5 ? "#166534" : "#6b7280";
                            }
                        }
                    },
                    y: {
                        type: "linear",
                        display: true,
                        position: "left",
                        grid: { color: "#f3f4f6" },
                        ticks: {
                            font: { size: 10 },
                            color: "#9ca3af",
                            callback: (val) => val + "M"
                        }
                    },
                    y1: {
                        type: "linear",
                        display: false,
                        position: "right",
                        grid: { drawOnChartArea: false }
                    }
                }
            }
        });
    }
}

