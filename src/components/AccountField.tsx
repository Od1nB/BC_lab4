import React from 'react';


interface Props {
    accs : string
}

const AccountField : React.FC<Props> = (props) => {
    return ( 
        <>
            <p>{props.accs}</p>
        </>
    );
}

export default AccountField;