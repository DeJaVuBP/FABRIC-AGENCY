<?php
session_start();
include_once "../model/supplier.php";

function createResponse(&$response, $error)
{
    if ($response == '') {
        $response .= "LỖI: " . $error;
    } else {
        $response .= ", " . $error;
    }
    return;
}

function validateData($table, $data)
{
    $response = '';
    switch ($table) {
        case 'supplier_phonenumber':
            if (empty($data['phone'])) return "Hãy nhập ít nhất 1 số điện thoại";
            foreach ($data['phone'] as $value) {
                if (!preg_match(Config::getRegex()['supplier_phonenumber']['phone'], $value)) {
                    createResponse($response, "Số điện thoại phải có ít nhất 10 số");
                    return $response;
                }
            }
            break;
        default:
            foreach ($data as $key => $value) {
                if (!preg_match(Config::getRegex()[$table][$key], $value)) {

                    createResponse($response, Config::getRegex()[$table][$key . "_Lỗi"]);
                    return $response;
                }
            }
    }
    return 'success';
}

function addNewSupplier($input_supplier)
{
    $phone_numbers['phone'] = isset($input_supplier['phone_numbers']) ? $input_supplier['phone_numbers'] : [];
    unset($input_supplier['phone_numbers']);

    $validation = validateData('supplier', $input_supplier);
    if ($validation != 'success') return $validation;

    $validation = validateData('supplier_phonenumber', $phone_numbers);
    if ($validation != 'success') return $validation;

    $status_id_supplier = Supplier::inputNewSupplier($input_supplier);
    if (!$status_id_supplier) return 'fail';

    $phone_numbers['ID'] = $status_id_supplier;

    $status_phone = Supplier::inputPhoneNumberSupplier($phone_numbers['ID'], $phone_numbers['phone']);
    return $status_phone ? 'success' : 'fail';
}

if (isset($_POST['inputSupplier'])) {
    echo (addNewSupplier($_POST['inputSupplier']));
}
