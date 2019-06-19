

// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

#ifndef AMQP_DEFINITIONS_MESSAGE_ID_STRING_H
#define AMQP_DEFINITIONS_MESSAGE_ID_STRING_H


#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdint.h>
#include <stdbool.h>
#endif

#include "azure_uamqp_c/amqpvalue.h"
#include "azure_c_shared_utility/umock_c_prod.h"


    typedef const char* message_id_string;

    MOCKABLE_FUNCTION(, AMQP_VALUE, amqpvalue_create_message_id_string, message_id_string, value);


    #define amqpvalue_get_message_id_string amqpvalue_get_string



#ifdef __cplusplus
}
#endif

#endif /* AMQP_DEFINITIONS_MESSAGE_ID_STRING_H */
