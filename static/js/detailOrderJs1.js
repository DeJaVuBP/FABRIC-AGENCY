const dateArr = ["Tháng Một", "Tháng Hai", "Tháng Ba", "Tháng Tư", "Tháng Năm", "Tháng Sáu", "Tháng Bảy", "Tháng Tám", "Tháng Chín", "Tháng Mười", "Tháng Mười Một", "Tháng Mười Hai"];


let table = $("#order-detail");

function getDateFormat(dateObj) {
    var dd = String(dateObj.getDate()).padStart(2, '0');
    var mm = dateArr[parseInt(String(dateObj.getMonth() + 1).padStart(2, '0'), 10) - 1];
    var yyyy = dateObj.getFullYear();
    return dd + " " + mm + ", " + yyyy;
}

function getURL(orderId, customerId) {
    return "application/controller/orderReport.php?orderId=" + orderId + "&customerId=" + customerId;
}

function getOrderDetail(url) {
    $.ajax({
        type: "GET",
        url: url,
        success: function(response) {
            var data = JSON.parse(response);
            renderHeader(data);
            renderInformation(data);
            renderEmployee(data);
            renderItemList(data);
            renderCustomerPhone(data);
        },
        async: false
    });
}

function renderHeader(orderInfo) {
    var cur_date = new Date();
    cur_date = getDateFormat(cur_date);
    $(
        `
		<tr class="top">
			<td colspan="12">
				<table>
					<tr>
						<td class="title">
							HÓA ĐƠN
						</td>
					
					</tr>	
					<tr>
						<td>
						273 An Dương Vương, Phường 3, Quận 5, Thành Phố Hồ Chí Minh <br> 0999999999
						</td>
						<td>
							Hóa đơn #: ${orderInfo.OrderID}
							<br> Ngày tạo: ${cur_date}
						</td>
					</tr>
				</table>
			</td>
		</tr>
		`
		// <td class="title">
						// 	ĐẠI_LÝ_VẢI_PTP
						// </td>
    ).appendTo(table);
}

function renderInformation(orderInfo) {
    $(
        `
		<tr class="information">
			<td colspan="12">
				<table>
					<tr>
						<td id="customer_phone_number">
							Tên Khách Hàng: ${orderInfo.customerName}<br>
							Địa Chỉ: ${orderInfo.customerAddress}<br>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		`
    ).appendTo(table);
}

function renderEmployee(orderInfo) {
    $(
        `
		<tr class="heading">
			<td colspan="2">
				Mã Nhân Viên
			</td>
			<td colspan="2">
				Tên Nhân Viên
			</td>
			<td colspan="2">
				Địa Chỉ
			</td>
			<td colspan="2">
				Số Điện Thoại
			</td>
			<td colspan="2">
				Ngày
			</td>
		</tr>

		<tr class="details">
			<td colspan="2">
				${orderInfo.employeeCode}
			</td>
			<td colspan="2">
				${orderInfo.employeeName}
			</td>
			<td colspan="2">
				${orderInfo.employeeAddress}
			</td>
			<td colspan="2">
				${orderInfo.phoneNumber}
			</td>
			<td colspan="2">
				${orderInfo.date}` + " " + `${orderInfo.time}
			</td>
        </tr>
		`
    ).appendTo(table);
}

function renderItemList(orderInfo) {
    $(
        `
		<tr class="heading">
			<td colspan="2">
				Mã Loại Vải
			</td>
			<td colspan="2">
				Tên Loại Vải
			</td>
			<td colspan="2">
				Màu Sắc
			</td>
			<td colspan="2">
				Mã Cuộn Vải
			</td>
			<td colspan="2">
				Chiều Dài
			</td>
		</tr>
		`
    ).appendTo(table);
    $.each(orderInfo.orderList, function(index, value) {
        $(
            `
			<tr class="item">
				<td colspan="2">
					${value.categoryCode}
				</td>
				<td colspan="2">
					${value.categoryName}
				</td>
				<td colspan="2">
					${value.color}
				</td>
				<td colspan="2">
					${value.boltCode}
				</td>
				<td colspan="2">
					${value.length}
				</td>
			</tr>
			`
        ).appendTo(table);
    });
	if (orderInfo.reasonCancel !== null) {
        $(
            `
			<tr class="total">
				<td colspan="5">
					Tổng tiền: ${orderInfo.totalPrice} <br>
					Trạng Thái: ${orderInfo.orderStatus} <br> 
					Lý do hủy: ${orderInfo.reasonCancel} <br>
				</td>
			</tr>
			`
        ).appendTo(table);
    } else {
        // Nếu reasonCancel là null, chỉ hiển thị các thông tin khác (không hiển thị lý do hủy)
		
        $( 
		`
        <tr class="total">
            <td colspan="5">
                Tổng tiền: ${orderInfo.totalPrice} <br>
                Trạng Thái: ${orderInfo.orderStatus} <br>
                Số tiền trả: ${orderInfo.partialPayment} <br>
                Ngày trả: ${orderInfo.datePay} <br>    
				Số tiền còn nợ: ${orderInfo.arrearage}
            </td>
        </tr>
        `
        ).appendTo(table);
    }

}


function renderCustomerPhone(orderInfo) {
    $.each(orderInfo.customerPhone, function(index, value) {
        $("#customer_phone_number").append(value.phoneNumber + "<br>");
    });
}

function generatePDF(orderId) {
    var content = $("#order-detail")[0];
    const pdf = new jsPDF({
        orientation: "landscape",
        unit: "in",
    });
    pdf.addHTML(content, function() {
        pdf.save('oderInvoice' + orderId + '.pdf');
    });
}

$(function() {
    let parameter = window.location.href.split("&");
    let orderId = parameter[0].split("=")[1];
    let customerId = parameter[1].split("=")[1];
    var url = getURL(orderId, customerId);
    getOrderDetail(url);
    $("#print-btn").click(() => generatePDF(orderId));
})