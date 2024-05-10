const transactionControllerUrl = "./application/controller/transaction.php"

var catList = [];
$(document).ready(function() {
    var cat_select = document.getElementById("catFilter");
    var sup_select = document.getElementById("supFilter");
    $.ajax({
        type: "GET",
        url: transactionControllerUrl,
        context: document.body,
        data: { catFilter: true, supFilter: true },
        success: function(responseText) {
            var obj = JSON.parse(responseText);
            obj["category"].forEach(i => {
                var opt = document.createElement('option');
                opt.value = i["id"];
                opt.text = i["category"];
                cat_select.append(opt);
            })

            obj["supplier"].forEach(i => {
                var opt = document.createElement('option');
                opt.value = i['ID'];
                opt.text = i['Name'];
                sup_select.append(opt);
            })
            refreshLiveSearch();
        },
        async: false
    })
    getAllTransaction();
})
$("#submit").click(function() {
    let catFilterVal = $("#catFilter option:selected").text() == "--Category--" ? "-1" : $("#catFilter option:selected").text();
    filterTransaction($("#edit_start").val(), $("#edit_end").val(), catFilterVal, $("#supFilter").val());
});
$("#edit_start").change(function() {
    var startDate = document.getElementById("edit_start").value;
    document.getElementById("edit_end").setAttribute("min", startDate);
});
$("#edit_end").change(function() {
    var endDate = document.getElementById("edit_end").value;
    document.getElementById("edit_start").setAttribute("max", endDate);
});
$("#catFilter").change(function() {
    $('select[id=supFilter]').val($("#catFilter").val());
    $('.selectpicker').selectpicker('refresh');
});
$("#supFilter").change(function() {
    $('select[id=catFilter]').val(-1);
    $('.selectpicker').selectpicker('refresh');
});

function filterTransaction(start, end, category, supplier) {
    var filter = {
        "start": "",
        "end": "",
        "category": "-1",
        "supplier": "-1"
    };
    filter["start"] = String(start);
    filter["end"] = String(end);
    filter["category"] = String(category);
    filter["supplier"] = String(supplier);
    if (filter["start"] == "" && filter["end"] == "" && filter["category"] == "-1" && filter["supplier"] == "-1") {
        document.getElementById("table_supplier").innerHTML = "";
        getAllTransaction();
    } else {
        filter = JSON.stringify(filter);
        $.ajax({
            type: "GET",
            url: transactionControllerUrl,
            context: document.body,
            data: { filterVal: filter },
            success: function(responseText) {
                var obj = JSON.parse(responseText);
                if (obj == 0) {
                    alert("Khong co");
                    return;
                }
                let transactionList = [];
                obj["transaction"].map((item, i) => {
                    for (let k = 0; k < obj["infor"].length; k++) {
                        if (item["supplierCode"] == obj["infor"][k]["supplierCode"]) {
                            let temp = Object.assign({}, item, obj["infor"][k])
                            transactionList.push(temp);
                        }
                    }
                });
                renderTransaction(transactionList);
                if (obj["supplier"] != undefined) {
                    generatateSupplierTable(obj["supplier"]);
                    $(".tooltiptext").remove();
                    $(".tooltip").removeClass("tooltip");
                } else {
                    document.getElementById("table_supplier").innerHTML = "";
                }
            },
            async: true
        })
    }
}

function getAllTransaction() {
    $.ajax({
        type: "GET",
        url: transactionControllerUrl,
        context: document.body,
        data: { getAll: true },
        success: function(responseText) {
            var obj = JSON.parse(responseText);
            let transactionList = [];
            obj["transaction"].map((item, i) => {
                for (let k = 0; k < obj["infor"].length; k++) {
                    if (item["supplierCode"] == obj["infor"][k]["supplierCode"]) {
                        let temp = Object.assign({}, item, obj["infor"][k])
                        transactionList.push(temp);
                    }
                }

            });
            renderTransaction(transactionList);
        },
        async: true
    })
}

function renderTransaction(transaction_list) {
    renderTableHeader();
    let table = document.getElementById("transaction_table");
    transaction_list.forEach(transaction => {
        let cat_name = transaction["categoryName"];
        let date = transaction["Date"];
        let price = transaction["purchasePrice"];
        let quantity = transaction["Quantity"];
        let supplier = transaction["supplierName"];
        let addr = transaction["address"];
        let bank = transaction["bankAccount"];
        let tax = transaction["taxCode"];
        let phone = transaction["phoneNumber"];
        let row = document.createElement("tr");
        row.innerHTML = `
                        <td>${cat_name}</td>
                        <td>${date}</td>
                        <td>${price}</td>
                        <td>${quantity}</td>
                        <td>
                            <div class="Supplier_InfoPopup">
                                <div id="Supplier_name">Tên: ${supplier}</div>
                                <div id="Supplier_address">Địa Chỉ: ${addr}</div>
                                <div id="Tax_code">Mã Số Thuế: ${tax}</div>
                                <div id="Bank_account">Tài Khoản Ngân Hàng: ${bank}</div>
                                <div id="Phone">SĐT: ${phone}</div>                                     
                            </div> 
                        </td>`;
        table.appendChild(row);
    })
}

function renderTableHeader() {
    let table = document.getElementById("transaction_table");
    table.innerHTML = `<tr>
    <th style="width: 20%;">Tên Loại Vải</th>
    <th style="width: 15%;">Ngày</th>
    <th style="width: 15%;">Giá Mua</th>
    <th style="width: 15%;">Số Lượng</th>
    <th style="width: 35%;">Nhà Cung Cấp</th>
</tr>`;
}

function refreshLiveSearch() {
    $('#catFilter').addClass('selectpicker');
    $('#catFilter').attr('data-live-search', 'true');
    $('#catFilter').selectpicker('refresh');
    $('#supFilter').addClass('selectpicker');
    $('#supFilter').attr('data-live-search', 'true');
    $('#supFilter').selectpicker('refresh');
}


function generatateSupplierTable(data) {
    var tablePosition = document.getElementById('table_supplier');
    tablePosition.innerHTML = '';
    var tbl = document.createElement('table');
    tbl.style.width = '100%';
    tbl.setAttribute('border', '1');
    tbl.insertAdjacentHTML('afterbegin', generateBodySupplierTable(data));
    tablePosition.appendChild(tbl);
}